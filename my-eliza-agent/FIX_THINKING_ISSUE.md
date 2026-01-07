# Fix Eliza "Thinking" Issue

## Problem
Eliza gets stuck in "thinking" state and doesn't respond to messages.

## Root Cause
The Docker container is not receiving API keys. The error in logs shows:
```
Error: No handler found for delegate type: TEXT_LARGE
```

This means no AI provider (OpenAI/Anthropic) is configured, so the agent can't process text messages.

## Solution

### Step 1: Verify API Keys in .env File

Open your `.env` file and ensure you have at least one valid API key:

```env
# Required: At least ONE of these must be set with a valid API key
OPENAI_API_KEY=sk-...your-actual-openai-key...
# OR
ANTHROPIC_API_KEY=sk-ant-...your-actual-anthropic-key...
```

**Important:** 
- The keys must NOT be empty
- They must be valid API keys (not placeholders like "your_openai_api_key_here")
- At least ONE must be set for the agent to work

### Step 2: Restart Docker Services

After updating the .env file:

```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"

# Stop services
docker-compose down

# Start services again (this will read the updated .env file)
docker-compose up -d

# Check logs to verify plugins loaded
docker-compose logs elizaos | Select-String -Pattern "plugin-openai|plugin-anthropic"
```

### Step 3: Verify API Keys in Container

Check if the container now has the API keys:

```powershell
docker-compose exec elizaos printenv | Select-String -Pattern "OPENAI_API_KEY|ANTHROPIC_API_KEY"
```

You should see actual key values (they'll be partially hidden, but not empty).

### Step 4: Check Logs for Plugin Loading

After restart, check logs to confirm the AI plugin loaded:

```powershell
docker-compose logs elizaos | Select-String -Pattern "plugin|handler|TEXT_LARGE"
```

You should see messages like:
- "plugin-openai" or "plugin-anthropic" in initialization
- No more "No handler found for delegate type: TEXT_LARGE" errors

## Getting API Keys

### OpenAI API Key
1. Visit: https://platform.openai.com/api-keys
2. Sign in or create account
3. Click "Create new secret key"
4. Copy the key (starts with `sk-`)
5. Add to `.env` file: `OPENAI_API_KEY=sk-...`

### Anthropic API Key
1. Visit: https://console.anthropic.com/
2. Sign in or create account
3. Go to API Keys section
4. Create a new key
5. Copy the key (starts with `sk-ant-`)
6. Add to `.env` file: `ANTHROPIC_API_KEY=sk-ant-...`

## Verify It's Working

After fixing:

1. **Restart the services** (see Step 2)
2. **Open http://localhost:3000** in your browser
3. **Send a test message** (e.g., "Hello")
4. **Eliza should respond** instead of getting stuck thinking

## Troubleshooting

### Still getting "No handler found"?
- Double-check the .env file has actual API keys (not placeholders)
- Make sure there are no extra spaces or quotes around the keys
- Restart Docker services after making changes

### API keys are set but still not working?
- Verify the keys are valid by testing them manually
- Check Docker logs for specific error messages
- Ensure docker-compose is reading from the correct .env file location

### Need to use a different AI provider?
- OpenAI: Set `OPENAI_API_KEY`
- Anthropic: Set `ANTHROPIC_API_KEY`
- OpenRouter: Set `OPENROUTER_API_KEY`
- Google GenAI: Set `GOOGLE_GENERATIVE_AI_API_KEY`

At least one AI provider is required for the agent to process messages!
