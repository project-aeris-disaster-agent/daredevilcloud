# ElizaOS Agent Cloud Deployment Guide

This guide walks you through deploying your elizaOS agent to the cloud step by step.

## Prerequisites

✅ Node.js v23+ installed  
✅ Bun installed  
✅ Docker installed (for containerized deployment)  
✅ API keys for your chosen AI provider (OpenAI, Anthropic, etc.)

## Step 1: Configure Environment Variables

### For Local Development

Create a `.env` file in the project root:

```bash
# Required: At least one AI provider API key
OPENAI_API_KEY=your_openai_api_key_here
# OR
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Database (for production, use PostgreSQL)
# For local dev with pglite, this is optional
POSTGRES_URL=postgresql://postgres:postgres@localhost:5432/eliza

# Server Configuration
SERVER_PORT=3000
ELIZA_UI_ENABLE=true
NODE_ENV=development
LOG_LEVEL=info

# Optional: Platform integrations
# DISCORD_API_TOKEN=your_discord_token
# TELEGRAM_BOT_TOKEN=your_telegram_token
```

### For Cloud Deployment

Create a `.env.production` file or set environment variables in your cloud platform:

```bash
# Required: AI Provider
OPENAI_API_KEY=your_openai_api_key_here

# Required: Production Database
POSTGRES_URL=postgresql://user:password@host:5432/eliza

# Server Configuration
SERVER_PORT=3000
ELIZA_UI_ENABLE=true
NODE_ENV=production
LOG_LEVEL=info
```

## Step 2: Test Locally

Before deploying, test your agent locally:

```bash
cd my-eliza-agent

# Set up environment variables
# Edit .env file with your API keys

# Start in development mode
elizaos dev

# Or start in production mode
elizaos start
```

Your agent should be available at:
- Web UI: http://localhost:3001 (or the port specified in SERVER_PORT)
- API: http://localhost:3001/api (or the port specified in SERVER_PORT)

## Step 3: Build Docker Image

### Option A: Using Docker Compose (Recommended for Local Testing)

```bash
# Build the image
docker-compose build

# Or build with a specific tag
docker build -t my-eliza-agent:latest .
```

### Option B: Build for Cloud Deployment

```bash
# Build the Docker image
docker build -t my-eliza-agent:latest .

# Tag for your container registry (e.g., Docker Hub, AWS ECR, etc.)
docker tag my-eliza-agent:latest your-registry/my-eliza-agent:latest
```

## Step 4: Deploy to Cloud

### Option 1: Deploy with Docker Compose (VPS/Cloud Server)

1. **Upload your project** to your cloud server (using scp, git, etc.)

2. **Set environment variables** on the server:
   ```bash
   # Create .env file on server
   nano .env
   # Add your production environment variables
   ```

3. **Start with Docker Compose**:
   ```bash
   docker-compose up -d
   ```

4. **Verify deployment**:
   ```bash
   docker-compose ps
   docker-compose logs -f elizaos
   ```

### Option 2: Deploy to Cloud Platforms

#### AWS (ECS/EKS/EC2)
- Push image to ECR
- Create ECS task definition or EKS deployment
- Configure environment variables in task/service definition
- Set up RDS PostgreSQL instance
- Update POSTGRES_URL in environment variables

#### Google Cloud (Cloud Run/GKE)
- Push image to GCR or Artifact Registry
- Deploy to Cloud Run or GKE
- Configure environment variables
- Set up Cloud SQL PostgreSQL
- Update POSTGRES_URL

#### Azure (Container Instances/AKS)
- Push image to Azure Container Registry
- Deploy to Container Instances or AKS
- Configure environment variables
- Set up Azure Database for PostgreSQL
- Update POSTGRES_URL

#### Railway
1. Connect your GitHub repository
2. Add environment variables in Railway dashboard
3. Railway will auto-detect Dockerfile and deploy
4. Add PostgreSQL service in Railway
5. Use Railway's POSTGRES_URL automatically provided

#### Render
1. Connect your GitHub repository
2. Create new Web Service
3. Set build command: `docker build -t my-eliza-agent .`
4. Set start command: `elizaos start`
5. Add environment variables in dashboard
6. Add PostgreSQL service
7. Use Render's DATABASE_URL

#### Fly.io
```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Launch app
fly launch

# Set secrets (environment variables)
fly secrets set OPENAI_API_KEY=your_key
fly secrets set POSTGRES_URL=your_postgres_url

# Deploy
fly deploy
```

#### Heroku
```bash
# Login to Heroku
heroku login

# Create app
heroku create my-eliza-agent

# Set environment variables
heroku config:set OPENAI_API_KEY=your_key
heroku config:set POSTGRES_URL=your_postgres_url

# Deploy
git push heroku main
```

## Step 5: Database Setup

### For Production: PostgreSQL

Your `docker-compose.yaml` includes PostgreSQL with pgvector. For cloud deployment:

1. **Use managed PostgreSQL** (recommended):
   - AWS RDS
   - Google Cloud SQL
   - Azure Database for PostgreSQL
   - Supabase
   - Neon
   - Railway PostgreSQL
   - Render PostgreSQL

2. **Update POSTGRES_URL**:
   ```
   POSTGRES_URL=postgresql://user:password@host:5432/database
   ```

3. **Enable pgvector extension** (if using managed PostgreSQL):
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

## Step 6: Verify Deployment

1. **Check health endpoint**:
   ```bash
   curl http://your-domain:3000/health
   ```

2. **Access web UI**:
   Open `http://your-domain:3000` in your browser

3. **Check logs**:
   ```bash
   # Docker Compose
   docker-compose logs -f elizaos
   
   # Docker
   docker logs -f container_name
   
   # Cloud platforms
   # Use platform-specific logging (CloudWatch, Stackdriver, etc.)
   ```

## Troubleshooting

### Agent not starting
- Check environment variables are set correctly
- Verify API keys are valid
- Check database connection (POSTGRES_URL)
- Review logs for specific errors

### Database connection issues
- Verify POSTGRES_URL format
- Check database is accessible from your deployment
- Ensure firewall rules allow connections
- Verify credentials are correct

### Port conflicts
- Change SERVER_PORT in environment variables
- Update port mappings in docker-compose.yaml
- Update cloud platform port configuration

## Next Steps

- Configure platform integrations (Discord, Telegram, etc.)
- Set up monitoring and logging
- Configure custom plugins
- Set up CI/CD for automated deployments
- Add domain and SSL certificate

## Resources

- [ElizaOS Documentation](https://eliza.how)
- [GitHub Repository](https://github.com/elizaOS/eliza)
- [Docker Documentation](https://docs.docker.com)
- [Deployment Guide](https://mountain-camp-f5a.notion.site/Simple-guide-to-deploy-your-elizaOS-agent-to-the-cloud-in-minutes-2d23c6aecc5480e98a91cbfe18b86dc1)
