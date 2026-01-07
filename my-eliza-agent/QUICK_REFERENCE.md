# Quick Reference - elizaOS Agent

## ✅ Current Status

Your elizaOS agent is **RUNNING** and accessible!

- **Web UI**: http://localhost:3001
- **API**: http://localhost:3001/api
- **Status**: ✅ Active

## 🚀 Quick Commands

### Start Development Server

**Option 1: Use helper script (easiest)**
```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
.\start-dev.ps1
```

**Option 2: Manual command**
```powershell
$env:Path += ";C:\Users\sedano\.bun\bin"
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
elizaos dev
```

**Option 3: After fixing PATH permanently**
```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
elizaos dev
```

### Stop Server
Press `Ctrl+C` in the terminal where it's running

### Other Commands
```powershell
# Start in production mode
elizaos start

# Check version
elizaos --version

# View help
elizaos --help
```

## 📁 Project Location
```
E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent
```

## 🔧 Configuration Files

- **`.env`** - Environment variables (API keys, settings)
- **`src/character.ts`** - Agent character configuration
- **`src/index.ts`** - Main entry point
- **`Dockerfile`** - Docker container configuration
- **`docker-compose.yaml`** - Docker Compose setup

## 🔑 API Key

Your Eliza API key is configured in `.env`:
```
OPENAI_API_KEY=eliza_437691750424d8f4d6f0fb5b82e9f9032d793b4d1f6262fb022a8c9c53cce88d
```

## 📚 Documentation Files

- **`FIX_PATH_AND_RUN.md`** - How to fix PATH issue permanently
- **`DEPLOYMENT.md`** - Complete cloud deployment guide
- **`QUICK_START.md`** - Quick start reference
- **`README.md`** - Project documentation

## 🌐 Access Your Agent

Once running, open in browser:
- **Web Interface**: http://localhost:3001
- **API Health**: http://localhost:3001/api/health (if available)

## 🐛 Troubleshooting

### Command not found?
See `FIX_PATH_AND_RUN.md` for permanent PATH fix

### Port 3001 in use?
Change `SERVER_PORT` in `.env` to another port (e.g., 3002)

### Agent won't start?
- Check `.env` file exists
- Verify API key is valid
- Check logs for errors

## 🚀 Next Steps

1. ✅ Agent is running locally
2. Test the web UI at http://localhost:3001
3. Customize your agent in `src/character.ts`
4. Deploy to cloud using `DEPLOYMENT.md`
