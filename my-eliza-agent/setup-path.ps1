# PowerShell script to permanently add Bun to PATH
# Run this script as Administrator or add to your PowerShell profile

$bunPath = "C:\Users\sedano\.bun\bin"

# Check if Bun path exists
if (Test-Path $bunPath) {
    # Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    # Check if Bun is already in PATH
    if ($currentPath -notlike "*$bunPath*") {
        # Add Bun to PATH
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$bunPath", "User")
        Write-Host "✅ Bun added to PATH successfully!" -ForegroundColor Green
        Write-Host "Please restart your terminal for changes to take effect." -ForegroundColor Yellow
    } else {
        Write-Host "✅ Bun is already in PATH" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Bun path not found at: $bunPath" -ForegroundColor Red
    Write-Host "Please verify Bun installation." -ForegroundColor Yellow
}
