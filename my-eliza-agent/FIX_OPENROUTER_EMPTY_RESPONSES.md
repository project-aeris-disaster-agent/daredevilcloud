# Fix OpenRouter Empty Response Issue

## Problem Analysis

Based on the system logs, your agent is experiencing the following issue:

### Symptoms (from logs):
1. **Empty LLM Responses**: 
   - `Raw LLM response received (responseLength=0, responsePreview=)`
   - The LLM is returning completely empty responses

2. **XML Parsing Failures**:
   - `Parsed XML content (parsedXml=null)`
   - `parseKeyValueXml returned null - XML parsing failed`
   - The framework expects XML-structured responses but receives nothing

3. **Agent Stops Responding**:
   - Without valid LLM responses, the agent cannot process messages
   - The message handling pipeline breaks when XML parsing fails

## Root Causes

### Most Likely: OpenRouter API Issues

1. **API Key Problems**:
   - Invalid or expired API key
   - API key not properly passed to the container
   - Missing or incorrect environment variable

2. **Quota/Credit Issues**:
   - OpenRouter account has no credits
   - Daily/monthly quota exhausted
   - Free tier limits reached

3. **Rate Limiting**:
   - Too many requests in a short time
   - OpenRouter rate limits being hit
   - Temporary rate limit enforcement

4. **Model Configuration Issues**:
   - Requested model not available
   - Model endpoint returning empty responses
   - Invalid model parameter format

5. **Network/Connection Issues**:
   - Container can't reach OpenRouter API
   - Timeout issues
   - DNS resolution problems

## Diagnosis Steps

### Step 1: Verify OpenRouter API Key

1. **Check if the API key is set in the container**:
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   docker-compose exec elizaos env | Select-String "OPENROUTER"
   ```

2. **Test the API key directly**:
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   .\test-openrouter.ps1
   ```

   This will test if:
   - The API key is valid
   - OpenRouter is accessible
   - You have credits/quota available

### Step 2: Check OpenRouter Account Status

1. Visit: https://openrouter.ai/keys
2. Check:
   - Account balance/credits
   - Usage statistics
   - Rate limit status
   - API key status (active/disabled)

### Step 3: Verify Environment Variables

1. **Check your .env file** (in `my-eliza-agent/.env`):
   ```env
   OPENROUTER_API_KEY=sk-or-v1-your-key-here
   ```

2. **Verify docker-compose is reading it**:
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   docker-compose config | Select-String "OPENROUTER"
   ```

### Step 4: Check Docker Container Logs

```powershell
cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
docker-compose logs elizaos | Select-String -Pattern "openrouter|OpenRouter|ERROR|error" -Context 3
```

Look for:
- Authentication errors
- Rate limit errors
- Model errors
- Network errors

## Solutions

### Solution 1: Fix API Key Configuration

1. **Ensure .env file exists and has the key**:
   ```env
   OPENROUTER_API_KEY=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
   ```

2. **Restart the container to reload environment variables**:
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   docker-compose down
   docker-compose up -d
   ```

3. **Verify the key is loaded**:
   ```powershell
   docker-compose exec elizaos env | Select-String "OPENROUTER"
   ```

### Solution 2: Add Credits to OpenRouter

1. Visit: https://openrouter.ai/credits
2. Add credits to your account (minimum usually $5-10)
3. Wait a few minutes for credits to activate
4. Restart the container:
   ```powershell
   docker-compose restart elizaos
   ```

### Solution 3: Use a Different AI Provider (Fallback)

If OpenRouter continues to have issues, switch to another provider:

#### Option A: Use OpenAI
```env
OPENAI_API_KEY=sk-your-openai-key
# Remove or comment out OPENROUTER_API_KEY
```

#### Option B: Use Anthropic
```env
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key
# Remove or comment out OPENROUTER_API_KEY
```

**Note**: You'll also need to update `character.ts` to remove the OpenRouter plugin if switching away:
```typescript
plugins: [
  '@elizaos/plugin-sql',
  // Remove: '@elizaos/plugin-openrouter',
  '@elizaos/plugin-ollama',
  // ... rest
]
```

### Solution 4: Check Model Configuration

The OpenRouter plugin might be trying to use a model that's:
- Not available
- Requires special permissions
- Has quota restrictions

Check the OpenRouter plugin logs for model-specific errors.

### Solution 5: Verify Network Connectivity

1. **Test from inside the container**:
   ```powershell
   docker-compose exec elizaos curl -I https://openrouter.ai
   ```

2. **Check DNS resolution**:
   ```powershell
   docker-compose exec elizaos nslookup openrouter.ai
   ```

## Immediate Action Plan

1. **First, test the API key**:
   ```powershell
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   .\test-openrouter.ps1
   ```

2. **If the test fails**:
   - Check OpenRouter account for credits
   - Verify the API key at https://openrouter.ai/keys
   - Generate a new API key if needed

3. **If the test passes but agent still fails**:
   - Check Docker logs for more specific errors
   - Verify environment variables are loaded in container
   - Check if there are model-specific issues

4. **As a temporary workaround**:
   - Switch to OpenAI or Anthropic if you have those API keys
   - This will get the agent responding while you fix OpenRouter

## Verification

After applying fixes:

1. **Restart the agent**:
   ```powershell
   docker-compose restart elizaos
   ```

2. **Monitor logs**:
   ```powershell
   docker-compose logs -f elizaos
   ```

3. **Test the agent**:
   - Open http://localhost:3000
   - Send a test message
   - Verify you get a response (not empty)

4. **Check logs for success**:
   - Look for successful LLM responses
   - Verify no more "responseLength=0" errors
   - Confirm XML parsing succeeds

## Expected Log Output (Success)

When working correctly, you should see:
- LLM responses with actual content
- Successful XML parsing
- Agent responding to messages

Example of good logs:
```
[SERVICE:MESSAGE] Raw LLM response received (responseLength=1523, responsePreview=<thought>...)
[SERVICE:MESSAGE] Parsed XML content (parsedXml={thought: "...", actions: [...]})
```

## Additional Notes

- **OpenRouter Plugin**: The `@elizaos/plugin-openrouter` plugin handles the API integration
- **Model Types**: The agent uses `ModelType.OBJECT_LARGE` which expects structured/XML responses
- **Empty Response Handling**: The framework expects XML but can't parse empty strings, causing failures
- **Rate Limits**: OpenRouter has rate limits - if you're hitting them, wait or upgrade your plan

## Still Not Working?

If issues persist after trying all solutions:

1. Check OpenRouter status page: https://status.openrouter.ai/
2. Review OpenRouter API documentation: https://openrouter.ai/docs
3. Check ElizaOS GitHub issues for known OpenRouter problems
4. Consider temporarily switching to OpenAI/Anthropic while debugging OpenRouter
