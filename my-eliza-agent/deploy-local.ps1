# Local Deployment Script for elizaOS Agent
# This script helps you deploy your agent locally with Docker

Write-Host "=== elizaOS Agent Local Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "1. Checking Docker..." -ForegroundColor Yellow
try {
    $dockerCheck = docker ps 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Docker is running" -ForegroundColor Green
    } else {
        Write-Host "   [FAIL] Docker is not running" -ForegroundColor Red
        Write-Host "   Please start Docker Desktop and try again" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   [FAIL] Docker is not running" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again" -ForegroundColor Yellow
    exit 1
}

# Check for .env file
Write-Host ""
Write-Host "2. Checking environment variables..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "   [OK] .env file found" -ForegroundColor Green
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "OPENAI_API_KEY|ANTHROPIC_API_KEY") {
        Write-Host "   [OK] AI provider API key found" -ForegroundColor Green
    } else {
        Write-Host "   [WARN] No AI provider API key found in .env" -ForegroundColor Yellow
        Write-Host "   You need at least one: OPENAI_API_KEY or ANTHROPIC_API_KEY" -ForegroundColor Yellow
    }
    
    if ($envContent -match "DOCKER_IMAGE") {
        Write-Host "   [OK] DOCKER_IMAGE configured" -ForegroundColor Green
    } else {
        Write-Host "   [WARN] DOCKER_IMAGE not found, will use default" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [FAIL] .env file not found" -ForegroundColor Red
    Write-Host "   Creating .env.example file..." -ForegroundColor Yellow
    @"
# Required: At least one AI provider API key
OPENAI_API_KEY=your_openai_api_key_here
# OR
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Database (use postgres as hostname for docker-compose)
POSTGRES_URL=postgresql://postgres:postgres@postgres:5432/eliza

# Server Configuration
SERVER_PORT=3000
ELIZA_UI_ENABLE=true
NODE_ENV=production
LOG_LEVEL=info

# Docker image name (required for docker-compose)
DOCKER_IMAGE=my-eliza-agent:latest
"@ | Out-File -FilePath ".env.example" -Encoding UTF8
    Write-Host "   Created .env.example - please copy to .env and add your API keys" -ForegroundColor Yellow
    Write-Host "   Copy .env.example to .env and edit with your API keys, then run this script again" -ForegroundColor Yellow
    exit 1
}

# Check if Docker image exists
Write-Host ""
Write-Host "3. Checking Docker image..." -ForegroundColor Yellow
$imageExists = docker images my-eliza-agent:latest -q
if ($imageExists) {
    Write-Host "   [OK] Docker image found" -ForegroundColor Green
    $rebuild = Read-Host "   Rebuild image? (y/N)"
    if ($rebuild -eq "y" -or $rebuild -eq "Y") {
        Write-Host "   Building Docker image..." -ForegroundColor Yellow
        docker build -t my-eliza-agent:latest .
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   [FAIL] Docker build failed" -ForegroundColor Red
            exit 1
        }
        Write-Host "   [OK] Docker image built successfully" -ForegroundColor Green
    }
} else {
    Write-Host "   [WARN] Docker image not found" -ForegroundColor Yellow
    Write-Host "   Building Docker image (this may take a few minutes)..." -ForegroundColor Yellow
    docker build -t my-eliza-agent:latest .
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   [FAIL] Docker build failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "   [OK] Docker image built successfully" -ForegroundColor Green
}

# Check if containers are running
Write-Host ""
Write-Host "4. Checking existing containers..." -ForegroundColor Yellow
$containers = docker-compose ps -q
if ($containers) {
    Write-Host "   [INFO] Containers are already running" -ForegroundColor Cyan
    Write-Host "   Stopping existing containers..." -ForegroundColor Yellow
    docker-compose down
}

# Start services
Write-Host ""
Write-Host "5. Starting services with Docker Compose..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Services started successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Deployment Complete ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your agent should be available at:" -ForegroundColor Cyan
    Write-Host "  - Web UI: http://localhost:3000" -ForegroundColor White
    Write-Host "  - API: http://localhost:3000/api" -ForegroundColor White
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Cyan
    Write-Host "  - View logs: docker-compose logs -f" -ForegroundColor White
    Write-Host "  - View agent logs: docker-compose logs -f elizaos" -ForegroundColor White
    Write-Host "  - Check status: docker-compose ps" -ForegroundColor White
    Write-Host "  - Stop services: docker-compose down" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "   [FAIL] Failed to start services" -ForegroundColor Red
    Write-Host "   Check logs with: docker-compose logs" -ForegroundColor Yellow
    exit 1
}
