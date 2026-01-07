# Fix Disk Space Issue for Docker Build

You're experiencing a disk space issue: **"ENOSPC: no space left on device"**

This prevents Docker from building images. Here's how to fix it:

## Quick Fix: Clean Up Docker

Docker can use a lot of disk space. Clean it up first:

### 1. Clean Docker System (Recommended First Step)

Run these commands in PowerShell (one at a time):

```powershell
# Remove all stopped containers, unused networks, and dangling images
docker system prune -a --volumes

# This will free up significant space. Confirm with 'y' when prompted.
```

**Warning:** This removes:
- All stopped containers
- All unused networks
- All dangling images
- All unused volumes
- All build cache

This is safe if you're not using other Docker projects.

### 2. More Aggressive Cleanup (if step 1 isn't enough)

```powershell
# Remove ALL containers (running and stopped)
docker container prune -a -f

# Remove ALL images
docker image prune -a -f

# Remove ALL volumes
docker volume prune -f

# Remove ALL build cache
docker builder prune -a -f
```

### 3. Check Docker Disk Usage

After cleanup, check how much space Docker is using:

```powershell
docker system df
```

## Other Disk Space Solutions

### Check Overall Disk Space

1. Open **File Explorer**
2. Right-click on **C:** drive
3. Select **Properties**
4. Check how much free space you have

### Free Up Space on Windows

1. **Disk Cleanup:**
   - Press `Win + R`, type `cleanmgr`, press Enter
   - Select C: drive
   - Check all boxes and click OK

2. **Remove Temporary Files:**
   ```powershell
   # Remove Windows temp files
   Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
   
   # Remove Windows Update files (if you're sure updates are applied)
   # Requires admin privileges:
   # Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
   ```

3. **Uninstall Unused Programs:**
   - Settings → Apps → Apps & features
   - Sort by size and uninstall what you don't need

4. **Empty Recycle Bin**

5. **Clear Browser Cache**

6. **Move Large Files to Another Drive:**
   - If you have another drive (D:, E:, etc.), move files there
   - Consider moving the project itself if E: has more space

## After Freeing Space

1. **Restart Docker Desktop** (to ensure it recognizes the freed space)

2. **Verify Docker is working:**
   ```powershell
   docker ps
   ```

3. **Retry the build:**
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   docker build -t my-eliza-agent:latest .
   ```

## Minimum Space Requirements

- **Docker Desktop:** ~4-5 GB
- **Base images:** ~1-2 GB
- **Build cache:** Can grow large over time
- **Your project build:** ~500 MB - 1 GB
- **Temporary files during build:** ~2-3 GB

**Recommended:** At least **10-15 GB free space** before building.

## Alternative: Build on a Different Drive

If C: drive is full, you can move Docker's data location:

1. **Change Docker Desktop settings:**
   - Open Docker Desktop
   - Settings → Resources → Advanced
   - Change "Disk image location" to a drive with more space (e.g., E:)
   - Click "Apply & Restart"

2. **Or move your project:**
   - If E: drive has space, consider moving your project there:
   ```powershell
   # Example: Move project to E: drive
   # Move "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent" to a location with more space
   ```

## Quick Command Reference

```powershell
# Check Docker disk usage
docker system df

# Clean everything Docker (safest)
docker system prune -a --volumes

# Check Windows disk space (File Explorer method is easier)
Get-PSDrive C | Format-Table Name,Used,Free,@{Name="UsedGB";Expression={[math]::Round($_.Used/1GB,2)}},@{Name="FreeGB";Expression={[math]::Round($_.Free/1GB,2)}}
```

## Need More Help?

If you continue having issues after freeing space:
1. Restart your computer
2. Restart Docker Desktop
3. Check Windows Update (sometimes pending updates reserve space)
4. Consider using a cloud build service instead (GitHub Actions, etc.)
