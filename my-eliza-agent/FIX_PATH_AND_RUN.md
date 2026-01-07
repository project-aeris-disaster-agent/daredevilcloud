# Fix PATH Issue and Run elizaOS - Step by Step Guide

## Problem
The `elizaos` command is not recognized because Bun's bin directory is not in your system PATH.

## ✅ Solution 1: Quick Fix (Current Session Only)

**Option A: Use the helper script**
```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
.\start-dev.ps1
```

**Option B: Manual command (run this every time you open a new terminal)**
```powershell
$env:Path += ";C:\Users\sedano\.bun\bin"
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
elizaos dev
```

## ✅ Solution 2: Permanent Fix (Recommended)

### Method 1: Add to PowerShell Profile (Recommended)

1. **Open PowerShell and run:**
```powershell
notepad $PROFILE
```

2. **If the file doesn't exist, create it:**
```powershell
New-Item -Path $PROFILE -Type File -Force
notepad $PROFILE
```

3. **Add this line to the file:**
```powershell
$env:Path += ";C:\Users\sedano\.bun\bin"
```

4. **Save and close Notepad**

5. **Reload your profile:**
```powershell
. $PROFILE
```

6. **Now you can use elizaos from anywhere:**
```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
elizaos dev
```

### Method 2: Add to System PATH (System-wide)

1. **Open System Properties:**
   - Press `Win + R`
   - Type `sysdm.cpl` and press Enter
   - Click "Environment Variables"

2. **Edit User PATH:**
   - Under "User variables", select "Path"
   - Click "Edit"
   - Click "New"
   - Add: `C:\Users\sedano\.bun\bin`
   - Click "OK" on all dialogs

3. **Restart your terminal/PowerShell**

4. **Verify it works:**
```powershell
elizaos --version
```

## 🚀 Running Your Agent

Once PATH is fixed, you can run:

```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"

# Development mode (with hot reloading)
elizaos dev

# OR production mode
elizaos start
```

Your agent will be available at:
- **Web UI**: http://localhost:3000
- **API**: http://localhost:3000/api

## 📋 Current Configuration

Your `.env` file is already configured with:
- ✅ Eliza API Key: `eliza_437691750424d8f4d6f0fb5b82e9f9032d793b4d1f6262fb022a8c9c53cce88d`
- ✅ Server Port: 3000
- ✅ UI Enabled: true
- ✅ Database: Using local pglite (no setup needed)

## 🔍 Troubleshooting

### Command still not found?
1. Verify Bun is installed:
   ```powershell
   C:\Users\sedano\.bun\bin\bun.exe --version
   ```

2. Check PATH:
   ```powershell
   $env:Path -split ';' | Select-String "bun"
   ```

3. Restart your terminal after adding to PATH

### Agent won't start?
- Check `.env` file exists and has your API key
- Verify API key is valid
- Check logs for specific errors

### Port 3000 already in use?
- Change `SERVER_PORT` in `.env` to a different port (e.g., 3001)
- Or stop the process using port 3000

## 📚 Next Steps

After your agent is running locally:
1. Test the web UI at http://localhost:3000
2. Test the API endpoints
3. Review `DEPLOYMENT.md` for cloud deployment options
