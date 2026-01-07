# Quick Deployment Guide

Follow these steps to deploy your agent with Docker.

## Prerequisites Checklist

- [x] Docker Desktop installed
- [ ] Docker Desktop running (start it from Start menu)
- [ ] Environment variables configured
- [ ] Docker image built

## Step 1: Start Docker Desktop

1. Open **Docker Desktop** from your Start menu
2. Wait for it to fully start (icon in system tray shows "Docker Desktop is running")
3. Verify it's working:
   ```powershell
   docker ps
   ```

## Step 2: Configure Environment Variables

Create a `.env` file in the project root (`my-eliza-agent/.env`) with your API keys:

```env
# Required: At least one AI provider API key
OPENAI_API_KEY=your_openai_api_key_here
# OR
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Database (will use PostgreSQL from docker-compose)
POSTGRES_URL=postgresql://postgres:postgres@postgres:5432/eliza

# Server Configuration
SERVER_PORT=3000
ELIZA_UI_ENABLE=true
NODE_ENV=production
LOG_LEVEL=info

# Docker image name (required for docker-compose)
DOCKER_IMAGE=my-eliza-agent:latest
```

**Note:** For the database URL in docker-compose, use `postgres` as the hostname (not `localhost`) since services communicate via Docker network.

## Step 3: Build Docker Image

Build your Docker image:

```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
docker build -t my-eliza-agent:latest .
```

This may take a few minutes the first time as it downloads base images and installs dependencies.

## Step 4: Test Locally with Docker Compose

Start the full stack (PostgreSQL + your agent):

```powershell
docker-compose up -d
```

This will:
- Start PostgreSQL with pgvector
- Start your elizaOS agent
- Set up networking between services

**Check logs:**
```powershell
# View all logs
docker-compose logs -f

# View only agent logs
docker-compose logs -f elizaos

# View only database logs
docker-compose logs -f postgres
```

**Check status:**
```powershell
docker-compose ps
```

**Access your agent:**
- Web UI: http://localhost:3000
- API: http://localhost:3000/api

## Step 5: Stop Services

When testing is complete:

```powershell
# Stop services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

## Next: Deploy to Cloud

Once local testing works, you can deploy to:
- Railway
- Render
- Fly.io
- AWS/GCP/Azure
- Any Docker-compatible platform

See `DEPLOYMENT.md` for cloud-specific instructions.

## Troubleshooting

### Docker not running
- Make sure Docker Desktop is started
- Check system tray for Docker icon

### Build fails
- Check you're in the correct directory
- Ensure Docker has enough resources (Settings → Resources)
- Check internet connection (needs to download base images)

### Container fails to start
- Check environment variables in `.env` file
- Verify API keys are correct
- Check logs: `docker-compose logs elizaos`

### Port already in use
- Change `SERVER_PORT` in `.env` file
- Or stop the service using port 3000

### Database connection issues
- Wait for PostgreSQL to be healthy: `docker-compose ps`
- Verify `POSTGRES_URL` uses `postgres` as hostname (not `localhost`)
