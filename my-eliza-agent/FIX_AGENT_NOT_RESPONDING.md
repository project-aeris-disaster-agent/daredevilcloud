# Fix Agent Not Responding Error

## Problem Summary

**ROOT CAUSE IDENTIFIED**: Your OpenRouter account has **insufficient credits**. 

The exact error from logs:
```
AI_APICallError: This request requires more credits, or fewer max_tokens. 
You requested up to 8192 tokens, but can only afford 7945.
```

Your agent is requesting **8192 max_tokens** but your account only has enough credits for **7945 tokens**. This causes OpenRouter to return a **402 Payment Required** error, resulting in empty responses.

## Immediate Solution

**Add credits to your OpenRouter account:**
1. Visit: https://openrouter.ai/settings/credits
2. Add at least $5-10 in credits
3. Wait 2-5 minutes for credits to activate
4. Restart the agent (it should work automatically)

---

Your agent is not responding because it's receiving **empty LLM responses** from OpenRouter. The logs show:

### Error Symptoms:
1. **Empty LLM Responses**: `Raw LLM response received (responseLength=0, responsePreview=)`
2. **XML Parsing Failures**: `parseKeyValueXml returned null - XML parsing failed`
3. **Missing Required Fields**: `Missing required fields (thought or actions), retrying (retries=3, maxRetries=3, hasThought=false, hasActions=false)`

### What This Means:
- The agent requests a response from OpenRouter
- OpenRouter returns an empty response (0 characters)
- The framework expects XML format like `<thought>...</thought><actions>...</actions>`
- Since the response is empty, parsing fails
- Without `thought` or `actions` fields, the agent cannot process the message
- The agent exhausts retries and stops responding

## Root Causes (Most Likely to Least Likely)

### 1. **OpenRouter Account Has No Credits** ⚠️ MOST COMMON
- OpenRouter requires credits to use their API
- Empty responses often indicate account has $0 balance
- Free tier may have been exhausted

### 2. **Invalid or Expired API Key**
- API key is incorrect or has been revoked
- Key format is wrong (should start with `sk-or-v1-`)

### 3. **API Key Not Loaded in Container**
- `.env` file doesn't exist or is in wrong location
- Docker container not reading environment variables
- API key not properly passed to container

### 4. **Rate Limiting**
- Too many requests in short time
- OpenRouter rate limits being hit
- Temporary rate limit enforcement

### 5. **Model Configuration Issues**
- Requested model not available
- Model endpoint returning empty responses
- Invalid model parameter format

## Immediate Diagnostic Steps

### Step 1: Test OpenRouter API Key

Run the test script to verify your API key works:

```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
.\test-openrouter.ps1
```

**Expected Output (Success):**
```
[OK] API Request successful!
Response: Hello
```

**Expected Output (Failure):**
```
[ERROR] API Request failed
Status: 401 (Unauthorized - invalid key)
or
Status: 402 (Payment Required - no credits)
```

### Step 2: Check OpenRouter Account Status

1. Visit: https://openrouter.ai/keys
2. Check:
   - **Account Balance/Credits** - Must have credits > $0
   - **Usage Statistics** - Check if you've hit limits
   - **API Key Status** - Must be "Active"
   - **Rate Limits** - Check if you're being rate limited

### Step 3: Verify Environment Variables

1. **Check if .env file exists** (in `my-eliza-agent/.env`):
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   Test-Path .env
   ```

2. **If .env exists, check contents**:
   ```powershell
   Get-Content .env | Select-String "OPENROUTER"
   ```

3. **If .env doesn't exist, create it**:
   ```env
   OPENROUTER_API_KEY=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
   POSTGRES_URL=postgresql://postgres:postgres@postgres:5432/eliza
   ```

4. **Verify docker-compose is reading it**:
   ```powershell
   docker-compose config | Select-String "OPENROUTER"
   ```

### Step 4: Check Container Logs

```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
docker-compose logs elizaos --tail 100 | Select-String -Pattern "openrouter|responseLength|parseKeyValueXml|Missing required|ERROR|error" -Context 2
```

Look for:
- Authentication errors (401)
- Payment required errors (402)
- Rate limit errors (429)
- Network/connection errors

## Solutions

### Solution 1: Add Credits to OpenRouter Account ⚡ QUICKEST FIX

1. **Visit**: https://openrouter.ai/credits
2. **Add Credits**: Minimum usually $5-10
3. **Wait**: 2-5 minutes for credits to activate
4. **Restart Container**:
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   docker-compose restart elizaos
   ```
5. **Test**: Send a message to the agent

### Solution 2: Verify and Fix API Key Configuration

1. **Get API Key from OpenRouter**:
   - Visit: https://openrouter.ai/keys
   - Copy your API key (starts with `sk-or-v1-`)

2. **Create/Update .env file**:
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   @"
   OPENROUTER_API_KEY=sk-or-v1-YOUR-ACTUAL-KEY-HERE
   POSTGRES_URL=postgresql://postgres:postgres@postgres:5432/eliza
   "@ | Out-File -FilePath .env -Encoding utf8
   ```

3. **Restart Container**:
   ```powershell
   docker-compose down
   docker-compose up -d
   ```

4. **Verify Key is Loaded**:
   ```powershell
   docker-compose exec elizaos env | Select-String "OPENROUTER"
   ```
   Should show: `OPENROUTER_API_KEY=sk-or-v1-...`

### Solution 3: Switch to Alternative AI Provider (Fallback)

If OpenRouter continues to have issues, switch to another provider:

#### Option A: Use OpenAI

1. **Get OpenAI API Key**: https://platform.openai.com/api-keys
2. **Update .env**:
   ```env
   OPENAI_API_KEY=sk-your-openai-key-here
   # Comment out or remove OPENROUTER_API_KEY
   ```
3. **Update character.ts** to remove OpenRouter plugin:
   ```typescript
   plugins: [
     '@elizaos/plugin-sql',
     // Remove: '@elizaos/plugin-openrouter',
     '@elizaos/plugin-ollama',
     // ... rest
   ]
   ```
4. **Restart**: `docker-compose restart elizaos`

#### Option B: Use Anthropic (Claude)

1. **Get Anthropic API Key**: https://console.anthropic.com/
2. **Update .env**:
   ```env
   ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
   ```
3. **Restart**: `docker-compose restart elizaos`

**Note**: You may still need embeddings from another provider.

### Solution 4: Fix Docker Environment Variable Loading

If the API key isn't being loaded into the container:

1. **Check docker-compose.yaml** - Should have:
   ```yaml
   environment:
     - OPENROUTER_API_KEY=${OPENROUTER_API_KEY:-}
   ```

2. **Ensure .env file is in same directory as docker-compose.yaml**

3. **Restart Docker Desktop** (if variables still not loading)

4. **Or manually pass environment variables**:
   ```powershell
   docker-compose down
   $env:OPENROUTER_API_KEY="sk-or-v1-YOUR-KEY"
   docker-compose up -d
   ```

## Verification Steps

After applying a solution:

1. **Test OpenRouter API**:
   ```powershell
   .\test-openrouter.ps1
   ```
   Should show successful API request.

2. **Check Container Logs**:
   ```powershell
   docker-compose logs -f elizaos
   ```
   Should see successful LLM responses, not empty ones.

3. **Test Agent**:
   - Open: http://localhost:3000
   - Send message: "Hello"
   - Should get a response (not stuck thinking)

4. **Look for Success Indicators in Logs**:
   ```
   [SERVICE:MESSAGE] Raw LLM response received (responseLength=1523, responsePreview=<thought>...)
   [SERVICE:MESSAGE] Parsed XML content (parsedXml={thought: "...", actions: [...]})
   ```

## Quick Fix Checklist

- [ ] Run `.\test-openrouter.ps1` - Does it pass?
- [ ] Check https://openrouter.ai/credits - Do you have credits > $0?
- [ ] Check https://openrouter.ai/keys - Is your key active?
- [ ] Verify `.env` file exists with `OPENROUTER_API_KEY`
- [ ] Restart container: `docker-compose restart elizaos`
- [ ] Test agent: Send message and verify response

## Still Not Working?

If issues persist:

1. **Check OpenRouter Status**: https://status.openrouter.ai/
2. **Review OpenRouter Docs**: https://openrouter.ai/docs
3. **Check Container Health**:
   ```powershell
   docker-compose ps
   ```
4. **Check Full Logs**:
   ```powershell
   docker-compose logs elizaos > logs.txt
   ```
   Review for any error messages.

5. **Try Alternative Provider**: Switch to OpenAI or Anthropic temporarily to isolate the issue.

## Summary

The agent stops responding because OpenRouter is returning empty responses. Most commonly this is due to:

1. ⚠️ **No credits** in OpenRouter account (add credits at https://openrouter.ai/credits)
2. Invalid/expired API key
3. API key not loaded in container

**Quickest Fix**: Add credits to OpenRouter account and restart the container.
