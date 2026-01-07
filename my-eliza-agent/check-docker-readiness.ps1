# Docker Readiness Check Script for Windows
# This script checks if your system is ready for Docker Desktop installation

Write-Host "=== Docker Desktop Readiness Check ===" -ForegroundColor Cyan
Write-Host ""

# Check Windows Version
Write-Host "1. Checking Windows Version..." -ForegroundColor Yellow
$osVersion = [System.Environment]::OSVersion.Version
$buildNumber = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
Write-Host "   OS Version: $($osVersion.Major).$($osVersion.Minor) (Build $buildNumber)" -ForegroundColor White

if ($osVersion.Major -eq 10 -and $osVersion.Minor -eq 0) {
    Write-Host "   [OK] Windows 10 detected" -ForegroundColor Green
} elseif ($osVersion.Major -eq 10 -and $osVersion.Minor -ge 22000) {
    Write-Host "   [OK] Windows 11 detected" -ForegroundColor Green
} else {
    Write-Host "   [WARN] Unsupported Windows version. Docker Desktop requires Windows 10 (Build 19041+) or Windows 11" -ForegroundColor Red
}

# Check WSL
Write-Host ""
Write-Host "2. Checking WSL Installation..." -ForegroundColor Yellow
$wslInstalled = Get-Command wsl -ErrorAction SilentlyContinue

if ($wslInstalled) {
    Write-Host "   [OK] WSL command found" -ForegroundColor Green
    
    try {
        $wslVersion = wsl --version 2>&1
        Write-Host "   WSL Version Info:" -ForegroundColor White
        Write-Host "   $wslVersion" -ForegroundColor Gray
        
        # Check WSL 2 default version
        $wslDefault = wsl --get-default-version 2>&1
        if ($wslDefault -match "2") {
            Write-Host "   [OK] WSL 2 is set as default" -ForegroundColor Green
        } else {
            Write-Host "   [WARN] WSL 2 is not set as default. Run: wsl --set-default-version 2" -ForegroundColor Yellow
        }
        
        # List WSL distributions
        $wslList = wsl --list --verbose 2>&1
        if ($wslList) {
            Write-Host "   Installed WSL Distributions:" -ForegroundColor White
            Write-Host "   $wslList" -ForegroundColor Gray
        }
    } catch {
        Write-Host "   [WARN] Could not check WSL details. WSL may need to be installed." -ForegroundColor Yellow
    }
} else {
    Write-Host "   [FAIL] WSL not found. You need to install WSL 2 first." -ForegroundColor Red
    Write-Host "   Run: wsl --install (as Administrator)" -ForegroundColor Yellow
}

# Check if Docker is already installed
Write-Host ""
Write-Host "3. Checking Docker Installation..." -ForegroundColor Yellow
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
$dockerComposeInstalled = Get-Command docker-compose -ErrorAction SilentlyContinue

if ($dockerInstalled) {
    Write-Host "   [OK] Docker is installed" -ForegroundColor Green
    try {
        $dockerVersion = docker --version
        Write-Host "   $dockerVersion" -ForegroundColor White
    } catch {
        Write-Host "   [WARN] Docker command found but may not be running" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [FAIL] Docker is not installed" -ForegroundColor Red
}

if ($dockerComposeInstalled) {
    Write-Host "   [OK] Docker Compose is installed" -ForegroundColor Green
    try {
        $composeVersion = docker-compose --version
        Write-Host "   $composeVersion" -ForegroundColor White
    } catch {
        Write-Host "   [WARN] Docker Compose command found but may not be working" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [FAIL] Docker Compose is not installed" -ForegroundColor Red
}

# Check virtualization support
Write-Host ""
Write-Host "4. Checking Virtualization Support..." -ForegroundColor Yellow
try {
    $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -ErrorAction SilentlyContinue
    if ($hyperv -and $hyperv.State -eq "Enabled") {
        Write-Host "   [OK] Hyper-V is available" -ForegroundColor Green
    } else {
        Write-Host "   [INFO] Hyper-V not enabled (not required if using WSL 2)" -ForegroundColor Gray
    }
} catch {
    Write-Host "   [INFO] Could not check Hyper-V status" -ForegroundColor Gray
}

# Check if running as Administrator
Write-Host ""
Write-Host "5. Checking Administrator Privileges..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "   [OK] Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "   [WARN] Not running as Administrator (may be needed for WSL installation)" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host ""

if (-not $dockerInstalled) {
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Install/update WSL 2:" -ForegroundColor White
    Write-Host "   wsl --install" -ForegroundColor Gray
    Write-Host "   wsl --set-default-version 2" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Download and install Docker Desktop:" -ForegroundColor White
    Write-Host "   https://www.docker.com/products/docker-desktop/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Restart your computer after WSL installation" -ForegroundColor White
    Write-Host ""
    Write-Host "See DOCKER_INSTALL.md for detailed instructions" -ForegroundColor Cyan
} elseif ($dockerInstalled -and -not $dockerComposeInstalled) {
    Write-Host "[WARN] Docker is installed but Docker Compose may be missing" -ForegroundColor Yellow
    Write-Host "  Docker Desktop includes Docker Compose. Try restarting Docker Desktop." -ForegroundColor White
} else {
    Write-Host "[OK] Your system appears ready for Docker!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Test Docker with:" -ForegroundColor Yellow
    Write-Host "  docker run hello-world" -ForegroundColor Gray
}

Write-Host ""
