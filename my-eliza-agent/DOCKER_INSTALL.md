# Docker Installation Guide for Windows

This guide will help you install Docker Desktop on Windows, which is required to deploy your elizaOS agent.

## Prerequisites

Before installing Docker Desktop, ensure your system meets these requirements:

✅ **Windows 10 64-bit**: Pro, Enterprise, or Education (Build 19041 or higher)
   - OR Windows 11 64-bit: Home or Pro (Build 22000 or higher)
   
✅ **WSL 2** (Windows Subsystem for Linux 2) - Docker Desktop uses WSL 2

✅ **Hardware requirements**:
   - 64-bit processor with Second Level Address Translation (SLAT)
   - 4GB system RAM minimum (8GB recommended)
   - BIOS-level hardware virtualization support must be enabled in the BIOS settings

## Step 1: Enable WSL 2

Docker Desktop requires WSL 2. If you don't have it installed, follow these steps:

### Option A: Install WSL 2 via Command Line (Recommended)

1. **Open PowerShell as Administrator**:
   - Press `Win + X` and select "Windows PowerShell (Admin)" or "Terminal (Admin)"
   - Or search for "PowerShell" in Start menu, right-click and select "Run as administrator"

2. **Run the WSL installation command**:
   ```powershell
   wsl --install
   ```

3. **Restart your computer** when prompted.

4. **After restart, set WSL 2 as default**:
   ```powershell
   wsl --set-default-version 2
   ```

5. **Verify WSL 2 is installed**:
   ```powershell
   wsl --list --verbose
   ```
   You should see your distribution with version "2".

### Option B: Enable via Windows Features (Alternative)

1. Press `Win + R`, type `optionalfeatures`, and press Enter
2. Enable "Windows Subsystem for Linux" and "Virtual Machine Platform"
3. Click OK and restart your computer

## Step 2: Install Docker Desktop

1. **Download Docker Desktop for Windows**:
   - Visit: https://www.docker.com/products/docker-desktop/
   - Or direct download: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe

2. **Run the installer**:
   - Double-click the downloaded `Docker Desktop Installer.exe`
   - Follow the installation wizard

3. **Configuration options** during installation:
   - ✅ Enable "Use WSL 2 instead of Hyper-V" (recommended)
   - ✅ Add shortcut to desktop (optional)
   - ✅ Start Docker Desktop after installation (recommended)

4. **Complete the installation**:
   - Click "Finish" when installation completes
   - Docker Desktop will start automatically

## Step 3: Verify Docker Installation

1. **Wait for Docker Desktop to start**:
   - You'll see a Docker icon in the system tray
   - Wait until it shows "Docker Desktop is running"

2. **Open PowerShell or Command Prompt** and run:
   ```powershell
   docker --version
   docker-compose --version
   ```

   You should see version information like:
   ```
   Docker version 24.x.x
   docker-compose version v2.x.x
   ```

3. **Test Docker with a simple command**:
   ```powershell
   docker run hello-world
   ```

   If successful, you'll see a message confirming Docker is working correctly.

## Step 4: Configure Docker Desktop (Optional but Recommended)

1. **Open Docker Desktop** from the Start menu or system tray

2. **Go to Settings** (gear icon):
   - **Resources → Advanced**: Adjust CPU and memory allocation (recommended: at least 2 CPUs and 4GB RAM)
   - **Resources → WSL Integration**: Enable integration with your WSL distributions
   - **General**: Enable "Start Docker Desktop when you log in" (optional)

3. **Apply & Restart** if you made changes

## Troubleshooting

### Issue: "WSL 2 installation is incomplete"

**Solution**:
```powershell
# Open PowerShell as Administrator and run:
wsl --update
wsl --set-default-version 2
```

Then restart your computer and try again.

### Issue: "Hardware-assisted virtualization and data execution protection must be enabled"

**Solution**:
1. Restart your computer and enter BIOS/UEFI settings (usually F2, F10, F12, or Del during boot)
2. Enable:
   - Virtualization Technology (VT-x for Intel or AMD-V for AMD)
   - Hyper-V (if available)
3. Save and exit BIOS
4. Restart Windows

### Issue: Docker Desktop won't start

**Solution**:
1. Check Windows Features:
   - Press `Win + R`, type `optionalfeatures`
   - Ensure "Virtual Machine Platform" and "Windows Hypervisor Platform" are enabled
   - Restart if you enabled any features

2. Check WSL 2 status:
   ```powershell
   wsl --status
   ```

3. Update WSL 2:
   ```powershell
   wsl --update
   ```

### Issue: Docker commands not recognized

**Solution**:
- Restart PowerShell/Command Prompt after installation
- Ensure Docker Desktop is running (check system tray)
- Verify Docker Desktop is in your PATH

## Next Steps

Once Docker is installed and working:

1. **Navigate to your project directory**:
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   ```

2. **Test Docker with your project**:
   ```powershell
   # Build the Docker image
   docker build -t my-eliza-agent:latest .

   # Or use docker-compose to test the full stack
   docker-compose build
   ```

3. **Follow the deployment guide**: See `DEPLOYMENT.md` for full deployment instructions.

## Additional Resources

- [Docker Desktop for Windows Documentation](https://docs.docker.com/desktop/install/windows-install/)
- [WSL 2 Installation Guide](https://learn.microsoft.com/en-us/windows/wsl/install)
- [Docker Desktop Troubleshooting](https://docs.docker.com/desktop/troubleshoot/overview/)

## Quick Verification Checklist

- [ ] WSL 2 is installed and set as default version
- [ ] Docker Desktop is installed and running
- [ ] `docker --version` command works
- [ ] `docker-compose --version` command works
- [ ] `docker run hello-world` executes successfully
- [ ] Docker Desktop shows "Docker Desktop is running" in system tray

Once all checkboxes are complete, you're ready to deploy your agent! 🐳
