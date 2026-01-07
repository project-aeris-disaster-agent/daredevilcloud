# Cleanup Database Script
# This script removes the PGLite database directory to allow for a fresh start

Write-Host "=== ElizaOS Database Cleanup ===" -ForegroundColor Cyan
Write-Host ""

$dbPath = ".\.eliza\.elizadb"

if (Test-Path $dbPath) {
    Write-Host "Found database directory at: $dbPath" -ForegroundColor Yellow
    
    # Try to remove PID file first
    $pidFile = Join-Path $dbPath "postmaster.pid"
    if (Test-Path $pidFile) {
        Write-Host "Removing stale postmaster.pid..." -ForegroundColor Yellow
        Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
    
    # Check for any processes using the database
    Write-Host "Checking for running elizaos processes..." -ForegroundColor Yellow
    $processes = Get-Process | Where-Object { $_.ProcessName -eq "elizaos" }
    
    if ($processes) {
        Write-Host "WARNING: Found running processes that might be using the database:" -ForegroundColor Red
        $processes | ForEach-Object {
            Write-Host "  - PID $($_.Id): $($_.ProcessName)" -ForegroundColor Yellow
        }
        Write-Host ""
        $response = Read-Host "Do you want to stop these processes? (Y/N)"
        if ($response -eq "Y" -or $response -eq "y") {
            $processes | Stop-Process -Force
            Write-Host "Processes stopped." -ForegroundColor Green
            Start-Sleep -Seconds 2
        } else {
            Write-Host "Skipping process termination. You may need to stop them manually." -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Removing database directory..." -ForegroundColor Yellow
    try {
        Remove-Item -Path $dbPath -Recurse -Force -ErrorAction Stop
        Write-Host "Database directory removed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "The database will be recreated on the next elizaos dev start." -ForegroundColor Cyan
    } catch {
        Write-Host "Error removing database directory: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "The directory might be locked. Try:" -ForegroundColor Yellow
        Write-Host "  1. Stopping all elizaos processes" -ForegroundColor Yellow
        Write-Host "  2. Closing any file explorers showing the .eliza folder" -ForegroundColor Yellow
        Write-Host "  3. Running this script again" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Database directory not found. Nothing to clean up." -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: elizaos dev" -ForegroundColor White
Write-Host "  2. The database will be automatically recreated" -ForegroundColor White
