# Fix Stuck Docker Commands

If your terminal gets stuck after running Docker commands, here are solutions:

## Issue: Terminal Stuck on Docker Prune

The `docker system prune` command often gets stuck because:
1. It's waiting for interactive confirmation (but not showing the prompt)
2. Docker Desktop is not responding
3. Network timeout connecting to Docker daemon

## Solutions

### Solution 1: Cancel and Use Non-Interactive Commands

1. **Cancel the stuck command:**
   - Press `Ctrl + C` to cancel
   - If that doesn't work, close the terminal window

2. **Use non-interactive commands with `-f` flag:**

```powershell
# Check Docker disk usage first (quick, shouldn't hang)
docker system df

# Clean without prompts (uses -f flag for "force")
docker system prune -a --volumes -f

# If that still hangs, try individual cleanups:
docker container prune -f
docker image prune -a -f
docker volume prune -f
docker network prune -f
docker builder prune -a -f
```

### Solution 2: Restart Docker Desktop

If commands are hanging, Docker Desktop might be frozen:

1. **Close Docker Desktop:**
   - Right-click Docker icon in system tray
   - Click "Quit Docker Desktop"

2. **Wait 10-15 seconds**

3. **Restart Docker Desktop:**
   - Open from Start menu
   - Wait until it fully starts (icon shows "Docker Desktop is running")

4. **Try the command again:**
   ```powershell
   docker ps
   ```

### Solution 3: Check Docker Daemon Connection

```powershell
# Test if Docker is responding
docker version

# Check Docker info (may hang if daemon is unresponsive)
docker info

# If these hang, Docker Desktop needs restart
```

### Solution 4: Use PowerShell with Explicit Docker Context

Sometimes PowerShell has issues with Docker output. Try:

```powershell
# Use explicit command formatting
docker system prune --all --volumes --force

# Or pipe output to avoid hanging
docker system prune -a -f 2>&1 | Out-String
```

### Solution 5: Clean Up via Docker Desktop GUI

If terminal commands keep hanging, use Docker Desktop's GUI:

1. Open **Docker Desktop**
2. Go to **Settings** (gear icon)
3. Click **Troubleshoot** → **Clean / Purge data**
4. Or use the **Disk usage** view to manually remove:
   - Images
   - Containers
   - Volumes
   - Build cache

## Quick Reference: Non-Interactive Cleanup Commands

```powershell
# Full cleanup (all with -f flag to avoid prompts)
docker system prune -a --volumes -f

# Individual cleanups (if full cleanup hangs):
docker container prune -f              # Remove stopped containers
docker image prune -a -f               # Remove unused images
docker volume prune -f                 # Remove unused volumes
docker network prune -f                # Remove unused networks
docker builder prune -a -f             # Remove build cache
```

## After Cleanup

Once cleanup completes (or you restart Docker Desktop), verify it's working:

```powershell
# Quick test
docker ps

# Check disk usage
docker system df

# Then try building again
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
docker build -t my-eliza-agent:latest .
```

## If Nothing Works

1. **Restart your computer** (sometimes Docker needs a full reset)
2. **Check Docker Desktop logs:**
   - Docker Desktop → Troubleshoot → View logs
3. **Consider reinstalling Docker Desktop** if it's consistently unresponsive
