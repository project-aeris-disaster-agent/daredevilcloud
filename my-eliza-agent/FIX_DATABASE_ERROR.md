# Fix Database Migration Error

## Problem
The error `Failed query: CREATE SCHEMA IF NOT EXISTS migrations` occurs when:
- The PGLite database is locked by a stale process
- The `postmaster.pid` file contains an invalid process ID
- Previous elizaos processes didn't shut down cleanly

## Solution

### Step 1: Stop All Running ElizaOS Processes

```powershell
# Stop all elizaos and bun processes (if safe to do so)
Get-Process | Where-Object { $_.ProcessName -eq "elizaos" } | Stop-Process -Force
Get-Process | Where-Object { $_.ProcessName -eq "bun" -and $_.Path -like "*eliza*" } | Stop-Process -Force
```

**OR** manually stop your `elizaos dev` command with `Ctrl+C`.

### Step 2: Clean Up Stale Lock Files

```powershell
cd "e:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
Remove-Item ".\.eliza\.elizadb\postmaster.pid" -Force -ErrorAction SilentlyContinue
```

### Step 3: If Problem Persists - Recreate Database Directory

If the error continues after Step 1 and 2, the database directory may be corrupted. You can safely delete it and let ElizaOS recreate it:

```powershell
cd "e:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"

# Backup important data first (if any)
# Then remove the database directory
Remove-Item -Recurse -Force ".\.eliza\.elizadb" -ErrorAction SilentlyContinue
```

**Note:** This will delete all local database data. ElizaOS will recreate a fresh database on the next start.

### Step 4: Restart ElizaOS

```powershell
elizaos dev
```

## Quick Fix Script

We've created a cleanup script to automate the process:

```powershell
cd "e:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
.\cleanup-database.ps1
```

This script will:
- Stop any running elizaos processes (with confirmation)
- Remove the stale lock file
- Delete the database directory
- Allow you to start fresh

## Prevention

- Always stop `elizaos dev` gracefully with `Ctrl+C`
- If the process crashes, run the cleanup script before restarting
- Consider using a full PostgreSQL instance for production (set `POSTGRES_URL` in `.env`)

## Alternative: Use Full PostgreSQL

For more reliability, you can use a full PostgreSQL instance instead of PGLite:

1. Start PostgreSQL using Docker Compose:
   ```powershell
   docker-compose up -d postgres
   ```

2. Update your `.env` file:
   ```
   POSTGRES_URL=postgresql://postgres:postgres@localhost:5432/eliza
   ```

3. Remove or comment out the PGLITE_DATA_DIR line from `.env`

4. Restart `elizaos dev`

**Note:** Using full PostgreSQL eliminates the PGLite lock file issues entirely.
