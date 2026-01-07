# Quick test script to verify agent is responding
Write-Host "Testing elizaOS agent..." -ForegroundColor Cyan
Write-Host ""

# Check if container is running
$status = docker-compose ps elizaos 2>&1 | Select-String "Up"
if ($status) {
    Write-Host "[OK] Agent container is running" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Agent container is not running" -ForegroundColor Red
    exit 1
}

# Check API key
Write-Host ""
Write-Host "Checking API key in container..." -ForegroundColor Yellow
$apiKey = docker-compose exec -T elizaos printenv OPENAI_API_KEY 2>&1 | Select-String "sk-"
if ($apiKey) {
    Write-Host "[OK] OPENAI_API_KEY is set in container" -ForegroundColor Green
} else {
    Write-Host "[ERROR] OPENAI_API_KEY is NOT set in container" -ForegroundColor Red
    Write-Host "  Make sure OPENAI_API_KEY is set in your .env file" -ForegroundColor Yellow
}

# Check health endpoint
Write-Host ""
Write-Host "Checking health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri http://localhost:3000/health -UseBasicParsing -TimeoutSec 5
    $health = $response.Content | ConvertFrom-Json
    if ($health.status -eq "OK") {
        Write-Host "[OK] Health check passed" -ForegroundColor Green
        Write-Host "  Agent count: $($health.agentCount)" -ForegroundColor White
    }
} catch {
    Write-Host "[ERROR] Health check failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Open http://localhost:3000 in your browser" -ForegroundColor White
Write-Host "2. Send a test message (e.g., 'Hello')" -ForegroundColor White
Write-Host "3. If Eliza still gets stuck thinking, check logs:" -ForegroundColor White
Write-Host "   docker-compose logs -f elizaos" -ForegroundColor Gray
Write-Host ""
