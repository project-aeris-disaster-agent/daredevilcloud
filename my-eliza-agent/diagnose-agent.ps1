# Diagnostic Script for Agent Not Responding Issue
# This script checks various aspects of the agent setup

Write-Host "=== Agent Diagnostic Script ===" -ForegroundColor Cyan
Write-Host ""

# Check 1: .env file exists
Write-Host "[1] Checking .env file..." -ForegroundColor Yellow
if (Test-Path .env) {
    Write-Host "  ✓ .env file exists" -ForegroundColor Green
    $envContent = Get-Content .env | Select-String "OPENROUTER"
    if ($envContent) {
        Write-Host "  ✓ OPENROUTER_API_KEY found in .env" -ForegroundColor Green
    } else {
        Write-Host "  ✗ OPENROUTER_API_KEY NOT found in .env" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ .env file does NOT exist" -ForegroundColor Red
}
Write-Host ""

# Check 2: Docker is running
Write-Host "[2] Checking Docker..." -ForegroundColor Yellow
$dockerCheck = docker --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Docker is installed and accessible" -ForegroundColor Green
} else {
    Write-Host "  ✗ Docker is not accessible: $dockerCheck" -ForegroundColor Red
}
Write-Host ""

# Check 3: Container status
Write-Host "[3] Checking container status..." -ForegroundColor Yellow
$containerStatus = docker ps -a --filter "name=elizaos" --format "{{.Names}}: {{.Status}}" 2>&1
if ($containerStatus -match "elizaos") {
    if ($containerStatus -match "Up") {
        Write-Host "  ✓ Container is running: $containerStatus" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Container exists but is NOT running: $containerStatus" -ForegroundColor Yellow
        Write-Host "     Run: docker-compose up -d" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✗ Container 'elizaos' not found" -ForegroundColor Red
    Write-Host "     Run: docker-compose up -d" -ForegroundColor Gray
}
Write-Host ""

# Check 4: API key in container
Write-Host "[4] Checking API key in container..." -ForegroundColor Yellow
$containerKey = docker-compose exec -T elizaos env 2>&1 | Select-String "OPENROUTER"
if ($containerKey) {
    Write-Host "  ✓ API key is loaded in container" -ForegroundColor Green
    $keyStr = $containerKey.ToString()
    if ($keyStr.Length -gt 50) {
        Write-Host "    Key: $($keyStr.Substring(0, 50))..." -ForegroundColor Gray
    } else {
        Write-Host "    Key: $keyStr" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ API key NOT found in container environment (container may not be running)" -ForegroundColor Yellow
    Write-Host "     Restart container: docker-compose restart elizaos" -ForegroundColor Gray
}
Write-Host ""

# Check 5: OpenRouter API test
Write-Host "[5] Testing OpenRouter API..." -ForegroundColor Yellow
if (Test-Path .env) {
    $envLines = Get-Content .env
    $apiKeyLine = $envLines | Select-String "OPENROUTER_API_KEY"
    if ($apiKeyLine) {
        $apiKey = $apiKeyLine.ToString().Split("=")[1].Trim()
        
        try {
            $headers = @{
                "Authorization" = "Bearer $apiKey"
                "Content-Type" = "application/json"
                "HTTP-Referer" = "http://localhost:3000"
                "X-Title" = "ElizaOS Test"
            }
            
            $body = @{
                model = "openai/gpt-3.5-turbo"
                messages = @(
                    @{
                        role = "user"
                        content = "Say hello"
                    }
                )
            } | ConvertTo-Json -Depth 10
            
            $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/chat/completions" `
                -Method Post `
                -Headers $headers `
                -Body $body `
                -ErrorAction Stop `
                -TimeoutSec 30
            
            if ($response.choices[0].message.content) {
                Write-Host "  ✓ OpenRouter API is working" -ForegroundColor Green
                Write-Host "    Response: $($response.choices[0].message.content)" -ForegroundColor Gray
            } else {
                Write-Host "  ✗ OpenRouter API returned empty response" -ForegroundColor Red
            }
        } catch {
            $statusCode = $null
            if ($_.Exception.Response) {
                $statusCode = $_.Exception.Response.StatusCode.value__
            }
            Write-Host "  ✗ OpenRouter API test failed" -ForegroundColor Red
            if ($statusCode) {
                Write-Host "    Status: $statusCode" -ForegroundColor Yellow
                if ($statusCode -eq 401) {
                    Write-Host "    → Invalid API key" -ForegroundColor Yellow
                } elseif ($statusCode -eq 402) {
                    Write-Host "    → Payment required (no credits)" -ForegroundColor Yellow
                } elseif ($statusCode -eq 429) {
                    Write-Host "    → Rate limited" -ForegroundColor Yellow
                }
            } else {
                Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  ⚠ OPENROUTER_API_KEY not found in .env file" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ .env file not found, skipping API test" -ForegroundColor Yellow
}
Write-Host ""

# Check 6: Container logs (recent errors)
Write-Host "[6] Checking recent container logs for errors..." -ForegroundColor Yellow
$logs = docker-compose logs elizaos --tail 50 2>&1
$errorLogs = $logs | Select-String -Pattern "responseLength=0|parseKeyValueXml|Missing required|ERROR|error" -Context 1

if ($errorLogs) {
    Write-Host "  ⚠ Found error messages in logs:" -ForegroundColor Yellow
    $errorLogs | Select-Object -First 5 | ForEach-Object {
        Write-Host "    $_" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✓ No obvious errors in recent logs" -ForegroundColor Green
}
Write-Host ""

# Summary and recommendations
Write-Host "=== Summary and Recommendations ===" -ForegroundColor Cyan
Write-Host ""

$recommendations = @()

# Check container status and provide recommendations
$containerStatusCheck = docker ps -a --filter "name=elizaos" --format "{{.Status}}" 2>&1
if (-not ($containerStatusCheck -match "Up")) {
    $recommendations += "1. Start the container: docker-compose up -d"
} else {
    # Container is running, check if key is loaded
    $containerKeyCheck = docker-compose exec -T elizaos env 2>&1 | Select-String "OPENROUTER"
    if (-not $containerKeyCheck) {
        $recommendations += "1. Restart container to load environment variables: docker-compose restart elizaos"
    }
}

$recommendations += "2. Test the agent: Open http://localhost:3000 and send a message"
$recommendations += "3. Monitor logs: docker-compose logs -f elizaos"
$recommendations += "4. If still failing, check OpenRouter credits: https://openrouter.ai/credits"

foreach ($rec in $recommendations) {
    Write-Host "  $rec" -ForegroundColor White
}

Write-Host ""
Write-Host "For detailed fix instructions, see: FIX_AGENT_NOT_RESPONDING.md" -ForegroundColor Cyan
