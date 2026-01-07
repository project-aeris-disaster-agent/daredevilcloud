# Fix OpenAI Quota/Insufficient Credits Issue

## Problem
Eliza gets stuck thinking and shows "Missing required fields (thought or actions)" error.

## Root Cause
Your OpenAI API key is valid, but your OpenAI account has:
- **Exceeded its quota/credit limit** 
- **No billing/payment method set up**
- **Reached rate limits** (429 errors)

The error in logs shows:
```
error: {
  type: "insufficient_quota",
  message: "You exceeded your current quota, please check your plan and billing details."
}
```

## Solutions

### Option 1: Add Billing to OpenAI Account (Recommended)

1. **Visit OpenAI Platform:**
   - Go to: https://platform.openai.com/account/billing
   
2. **Add Payment Method:**
   - Click "Add payment method"
   - Enter your credit card details
   - Set up billing

3. **Add Credits:**
   - Add credits to your account (minimum is usually $5-10)
   - Wait a few minutes for the credits to activate

4. **Restart Eliza:**
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   docker-compose restart elizaos
   ```

### Option 2: Use Anthropic (Claude) Instead

If you prefer not to use OpenAI, switch to Anthropic:

1. **Get Anthropic API Key:**
   - Visit: https://console.anthropic.com/
   - Sign up and get your API key (starts with `sk-ant-`)

2. **Update .env file:**
   ```env
   # Remove or comment out OpenAI
   # OPENAI_API_KEY=...
   
   # Add Anthropic
   ANTHROPIC_API_KEY=sk-ant-your-key-here
   ```

3. **Restart services:**
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

**Note:** According to your character.ts, if you use Anthropic, you'll still need embeddings from another provider (like OpenAI) or you can disable embeddings.

### Option 3: Use OpenRouter (Multiple Providers)

OpenRouter gives access to multiple AI models:

1. **Get OpenRouter API Key:**
   - Visit: https://openrouter.ai/
   - Sign up and get your API key

2. **Update .env file:**
   ```env
   # Use OpenRouter instead
   OPENROUTER_API_KEY=your-openrouter-key
   ```

3. **Restart services:**
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

### Option 4: Use Local AI (Ollama) - Free

For local development, you can use Ollama:

1. **Install Ollama:**
   - Download from: https://ollama.ai/
   - Install and start Ollama

2. **Update .env file:**
   ```env
   # Set Ollama endpoint
   OLLAMA_API_ENDPOINT=http://host.docker.internal:11434
   ```

3. **Note:** This requires running Ollama on your local machine and may have different performance.

## Verify Fix

After applying a solution:

1. **Check logs:**
   ```powershell
   docker-compose logs -f elizaos
   ```

2. **Test in browser:**
   - Open http://localhost:3000
   - Send a test message
   - Should respond without getting stuck

## Check Your OpenAI Account Status

Visit these URLs to check your account:
- **Billing:** https://platform.openai.com/account/billing
- **Usage:** https://platform.openai.com/usage
- **API Keys:** https://platform.openai.com/api-keys

## Temporary Workaround

If you need to test immediately and don't want to add billing:

1. **Disable embeddings** (which are causing many API calls):
   - Add to `.env`: `DISABLE_EMBEDDINGS=true` (if supported)
   - Or use Anthropic + OpenAI embeddings only

2. **Reduce rate of requests** by limiting agent activity

## Summary

The agent is working correctly, but your OpenAI account needs billing/credits. Choose one:
- ✅ **Quick fix:** Add billing to OpenAI account
- ✅ **Alternative:** Switch to Anthropic API
- ✅ **Budget option:** Use OpenRouter
- ✅ **Local option:** Use Ollama (free, local)

Once you have a working API provider with credits, Eliza will respond normally!
