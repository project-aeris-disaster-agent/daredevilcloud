# Test OpenRouter API Key
$apiKey = "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"

Write-Host "Testing OpenRouter API..." -ForegroundColor Cyan
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
    Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response body: $responseBody" -ForegroundColor Gray
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
Write-Host "If Test 1 failed, check:" -ForegroundColor White
Write-Host "  1. API key is correct" -ForegroundColor Gray
Write-Host "  2. You have credits on OpenRouter account" -ForegroundColor Gray
Write-Host "  3. Network connection is working" -ForegroundColor Gray
