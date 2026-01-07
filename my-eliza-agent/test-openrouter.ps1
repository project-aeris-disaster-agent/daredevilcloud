# Test OpenRouter API Key
# Reads API key from .env file

# Load API key from .env
$envPath = Join-Path $PSScriptRoot ".env"
$apiKey = $null

if (Test-Path $envPath) {
    Get-Content $envPath | ForEach-Object {
        if ($_ -match "^OPENROUTER_API_KEY=(.+)$") {
            $apiKey = $matches[1].Trim()
        }
    }
}

if (-not $apiKey) {
    Write-Host "[ERROR] OPENROUTER_API_KEY not found in .env file" -ForegroundColor Red
    Write-Host "Please add it to: $envPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "Testing OpenRouter API..." -ForegroundColor Cyan
Write-Host "Using key: $($apiKey.Substring(0, 15))...***" -ForegroundColor Gray
Write-Host ""

# Test 1: Simple completion request
Write-Host "Test 1: Simple API request..." -ForegroundColor Yellow
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
                content = "Say hello in one word"
            }
        )
    } | ConvertTo-Json -Depth 10
    
    $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/chat/completions" `
        -Method Post `
        -Headers $headers `
        -Body $body `
        -ErrorAction Stop
    
    Write-Host "[OK] API Request successful!" -ForegroundColor Green
    Write-Host "Response: $($response.choices[0].message.content)" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "[ERROR] API Request failed" -ForegroundColor Red
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host "Status: $statusCode" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response body: $responseBody" -ForegroundColor Gray
        
        # Provide specific guidance based on error
        Write-Host ""
        if ($statusCode -eq 401) {
            Write-Host ">>> FIX: Your API key is INVALID or EXPIRED" -ForegroundColor Red
            Write-Host "    1. Go to: https://openrouter.ai/settings/keys" -ForegroundColor Yellow
            Write-Host "    2. Create a new API key" -ForegroundColor Yellow
            Write-Host "    3. Update OPENROUTER_API_KEY in .env" -ForegroundColor Yellow
        } elseif ($statusCode -eq 402) {
            Write-Host ">>> FIX: Insufficient credits" -ForegroundColor Red
            Write-Host "    Go to: https://openrouter.ai/settings/credits" -ForegroundColor Yellow
            Write-Host "    Add at least $5-10 in credits" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

# Test 2: Check account status
Write-Host "Test 2: Checking account status..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $apiKey"
    }
    
    $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/auth/key" `
        -Method Get `
        -Headers $headers `
        -ErrorAction Stop
    
    Write-Host "[OK] Account check successful!" -ForegroundColor Green
    Write-Host "Key info:" -ForegroundColor White
    $response | Format-List
    Write-Host ""
    
} catch {
    Write-Host "[WARN] Could not check account status (this is optional)" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "If Test 1 passed, the API key is working and OpenRouter is accessible." -ForegroundColor White
Write-Host "If Test 1 failed with 401, your API key is invalid - get a new one." -ForegroundColor White
Write-Host "If Test 1 failed with 402, you need to add credits." -ForegroundColor White
Write-Host ""
Write-Host "OpenRouter Dashboard: https://openrouter.ai" -ForegroundColor Cyan
