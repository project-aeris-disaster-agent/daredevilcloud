# Fix: OpenRouter Insufficient Credits Error

## 🔴 CRITICAL ERROR IDENTIFIED

Your agents are failing with this exact error:

```
AI_APICallError: This request requires more credits, or fewer max_tokens. 
You requested up to 8192 tokens, but can only afford 7945. 
To increase, visit https://openrouter.ai/settings/credits and upgrade to a paid account

statusCode: 402 (Payment Required)
```

## What's Happening

1. **Agent requests**: 8192 max_tokens from OpenRouter
2. **OpenRouter responds**: "You don't have enough credits - only enough for 7945 tokens"
3. **Error code**: 402 (Payment Required)
4. **Result**: Empty response → XML parsing fails → Agent retries → Same error → Agent stops responding

## Immediate Fix (Required)

### Option 1: Add Credits to OpenRouter ⚡ **FASTEST**

1. **Visit**: https://openrouter.ai/settings/credits
2. **Add Credits**: Minimum $5-10 (more is better for testing)
3. **Wait**: 2-5 minutes for credits to activate
4. **Restart Agent** (if needed):
   ```powershell
   # Stop current agent (Ctrl+C in terminal)
   # Then restart:
   cd "E:\NPC\AGENT 14\daredevilcloud\my-eliza-agent"
   elizaos start
   ```

**That's it!** The agent should work immediately after credits are added.

### Option 2: Reduce max_tokens (Workaround)

If you can't add credits immediately, you could modify the code to reduce max_tokens, but this requires code changes and may affect functionality.

**Not recommended** - adding credits is easier and better.

### Option 3: Switch to Different AI Provider

If you have other API keys available:

#### Use OpenAI:
```env
OPENAI_API_KEY=sk-your-openai-key-here
# Comment out or remove OPENROUTER_API_KEY
```

#### Use Anthropic:
```env
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
# Comment out or remove OPENROUTER_API_KEY
```

**Note**: You'll need to update `character.ts` to remove the OpenRouter plugin if switching away.

## Verification

After adding credits:

1. **Check account balance**: https://openrouter.ai/settings/credits
   - Should show credits > $0

2. **Test agent**:
   - Open: http://localhost:3001 (or the port shown in logs)
   - Send a message
   - Should get a response (not empty)

3. **Check logs**:
   - Should see successful LLM responses
   - No more "402" or "Payment Required" errors
   - Should see: `Raw LLM response received (responseLength=XXXX, responsePreview=<thought>...)`

## Why This Happened

- Free tier or low-balance account
- Agent using high `max_tokens` (8192) setting
- Account ran out of credits
- OpenRouter enforces credit limits strictly

## Prevention

1. **Monitor credits regularly**: https://openrouter.ai/settings/credits
2. **Set up alerts**: Configure email alerts when credits are low
3. **Use auto-recharge**: Enable automatic credit top-ups if available
4. **Consider paid plan**: Upgrade for better limits and reliability

## Summary

**Problem**: OpenRouter account has insufficient credits (only enough for 7945 tokens, but agent requests 8192).

**Solution**: Add credits at https://openrouter.ai/settings/credits

**Time to fix**: ~5 minutes (2-5 min for credits to activate)

**Cost**: Minimum $5-10 to get started
