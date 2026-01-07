# PowerShell script to start elizaOS in development mode
# This script fixes the PATH issue and starts the dev server

# Add Bun to PATH for this session
$env:Path += ";C:\Users\sedano\.bun\bin"

# Navigate to project directory
Set-Location "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"

Write-Host "🚀 Starting elizaOS in development mode..." -ForegroundColor Green
Write-Host "📍 Project directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host "🔑 Using API key from .env file" -ForegroundColor Cyan
Write-Host ""

# Start elizaOS dev
elizaos dev
