# Fix Unauthorized Access Error

## Problem
Getting "unauthorized access" or 401 errors when making API requests to elizaOS server.

## Solution

The `ELIZA_SERVER_AUTH_TOKEN` you have configured is used to authenticate API requests to your elizaOS server. Here's how to use it correctly:

### 1. Verify Token is Set in Environment

Your token is already set in `.env`:
```
ELIZA_SERVER_AUTH_TOKEN=eliza_437691750424d8f4d6f0fb5b82e9f9032d793b4d1f6262fb022a8c9c53cce88d
```

### 2. Include Token in API Requests

When making API requests to your elizaOS server, include the token in the Authorization header:

**For cURL:**
```bash
curl -H "Authorization: Bearer eliza_437691750424d8f4d6f0fb5b82e9f9032d793b4d1f6262fb022a8c9c53cce88d" \
     http://localhost:3000/api/agents
```

**For JavaScript/TypeScript (fetch):**
```javascript
const response = await fetch('http://localhost:3000/api/agents', {
  headers: {
    'Authorization': `Bearer ${process.env.ELIZA_SERVER_AUTH_TOKEN}`,
    'Content-Type': 'application/json'
  }
});
```

**For Python (requests):**
```python
import os
import requests

token = os.getenv('ELIZA_SERVER_AUTH_TOKEN')
headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}
response = requests.get('http://localhost:3000/api/agents', headers=headers)
```

**For Postman/Insomnia:**
1. Set header: `Authorization`
2. Value: `Bearer eliza_437691750424d8f4d6f0fb5b82e9f9032d793b4d1f6262fb022a8c9c53cce88d`

### 3. Alternative: Check if Token Format is Correct

Some elizaOS versions might expect the token without the "Bearer" prefix, or with a different format:

**Try without "Bearer":**
```bash
curl -H "Authorization: eliza_437691750424d8f4d6f0fb5b82e9f9032d793b4d1f6262fb022a8c9c53cce88d" \
     http://localhost:3000/api/agents
```

**Or as a custom header:**
```bash
curl -H "X-API-Key: eliza_437691750424d8f4d6f0fb5b82e9f9032d793b4d1f6262fb022a8c9c53cce88d" \
     http://localhost:3000/api/agents
```

### 4. Verify Server is Reading the Token

Check if the server started successfully and is reading the environment variable:

```powershell
# Check if server is running
Get-Process | Where-Object { $_.ProcessName -eq "elizaos" }

# Check server logs for any auth-related messages
# Look for logs when you start elizaos dev
```

### 5. Test the Token

Test if your token works with a simple API call:

```powershell
# PowerShell
$token = "eliza_437691750424d8f4d6f0fb5b82e9f9032d793b4d1f6262fb022a8c9c53cce88d"
Invoke-RestMethod -Uri "http://localhost:3000/api/agents" -Headers @{Authorization = "Bearer $token"}
```

### 6. Check Server Configuration

Make sure your server is configured to require authentication. Some endpoints might be public while others require auth. Check your server logs when making requests to see what's happening.

### 7. Regenerate Token (if needed)

If the token isn't working, you may need to regenerate it. Check the elizaOS documentation or regenerate it through the server.

## Common Issues

1. **Token not being read from .env**: Make sure you restarted `elizaos dev` after adding the token
2. **Wrong header format**: Try both `Bearer <token>` and just `<token>`
3. **Server not requiring auth**: Some endpoints might not require authentication
4. **Token expired/invalid**: The token might need to be regenerated

## Debugging Steps

1. **Enable verbose logging**:
   ```
   LOG_LEVEL=debug
   ```

2. **Check server response**:
   ```powershell
   # See full error response
   Invoke-WebRequest -Uri "http://localhost:3000/api/agents" -Headers @{Authorization = "Bearer $token"} -UseBasicParsing
   ```

3. **Check if endpoint requires auth**:
   Try accessing without the token first to see if it's a public endpoint.

## Next Steps

If you're still getting unauthorized errors:
1. Share the exact error message and HTTP status code
2. Share which endpoint you're calling
3. Share server logs around the time of the request
4. Verify the server version and check if there are any known auth issues
