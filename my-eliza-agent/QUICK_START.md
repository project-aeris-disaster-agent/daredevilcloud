# Quick Start Guide - ElizaOS Agent Deployment

## ✅ Completed Steps

1. ✅ Installed Bun package manager
2. ✅ Installed elizaOS CLI globally
3. ✅ Created project: `my-eliza-agent`

## 🚀 Next Steps

### Step 1: Configure Environment Variables

Create a `.env` file in the `my-eliza-agent` directory:

**Minimum required configuration:**
```bash
# At least one AI provider API key is required
OPENAI_API_KEY=your_openai_api_key_here

# Server settings
SERVER_PORT=3000
ELIZA_UI_ENABLE=true
NODE_ENV=development
LOG_LEVEL=info
```

**For production deployment, also add:**
```bash
# PostgreSQL database URL (required for production)
POSTGRES_URL=postgresql://user:password@host:5432/eliza
```

### Step 2: Test Locally

```bash
cd my-eliza-agent

# Start in development mode (with hot reloading)
elizaos dev

# OR start in production mode
elizaos start
```

Access your agent:
- Web UI: http://localhost:3000
- API: http://localhost:3000/api

### Step 3: Build Docker Image

```bash
# From the my-eliza-agent directory
docker build -t my-eliza-agent:latest .
```

### Step 4: Test with Docker Compose

```bash
# Set DOCKER_IMAGE environment variable
$env:DOCKER_IMAGE="my-eliza-agent:latest"

# Start services
docker-compose up -d

# View logs
docker-compose logs -f elizaos
```

### Step 5: Deploy to Cloud

Choose your deployment platform and follow the instructions in `DEPLOYMENT.md`.

**Popular options:**
- **Railway**: Connect GitHub repo, add env vars, deploy
- **Render**: Connect GitHub repo, add PostgreSQL, deploy
- **Fly.io**: Use `fly launch` and `fly deploy`
- **AWS/GCP/Azure**: Push to container registry, deploy to ECS/GKE/AKS

## 📋 Environment Variables Reference

### Required
- `OPENAI_API_KEY` OR `ANTHROPIC_API_KEY` (at least one AI provider)

### Production Required
- `POSTGRES_URL` (PostgreSQL connection string)

### Optional
- `DISCORD_API_TOKEN` - Discord bot integration
- `TELEGRAM_BOT_TOKEN` - Telegram bot integration
- `SERVER_PORT` - Server port (default: 3000)
- `LOG_LEVEL` - Logging level (default: info)

See `DEPLOYMENT.md` for complete environment variable reference.

## 🔍 Troubleshooting

**Agent won't start?**
- Check your API key is valid
- Verify `.env` file exists and has correct values
- Check logs: `elizaos start` will show errors

**Docker build fails?**
- Ensure Docker is running
- Check you're in the `my-eliza-agent` directory
- Verify Node.js v23+ is available in Docker

**Database connection issues?**
- Verify POSTGRES_URL format
- Check database is accessible
- For local dev, pglite is used automatically (no setup needed)

## 📚 Documentation

- Full deployment guide: `DEPLOYMENT.md`
- ElizaOS docs: https://eliza.how
- GitHub: https://github.com/elizaOS/eliza
