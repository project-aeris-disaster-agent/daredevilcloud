# Polymarket Plugin Setup Guide

## ✅ Installation Complete

The Polymarket plugin has been successfully installed and integrated into your elizaOS agent!

## 📦 What Was Installed

1. **Plugin Source**: Copied to `src/plugins/polymarket/`
2. **Dependencies**: 
   - `@polymarket/clob-client` - Official Polymarket API client
   - `ethers` - Ethereum library for wallet operations
   - `node-fetch` - HTTP client
   - `ws` - WebSocket support
3. **Integration**: Plugin added to `src/index.ts`

## 🔧 Configuration

### Environment Variables

The following environment variables have been added to your `.env` file:

```bash
# For L1 authentication (wallet operations)
WALLET_PRIVATE_KEY=your_wallet_private_key_here

# For L2 authentication (API operations) - Recommended
# Create API keys using the CREATE_API_KEY action first
CLOB_API_KEY=your_api_key_here
CLOB_API_SECRET=your_api_secret_here
CLOB_API_PASSPHRASE=your_api_passphrase_here

# Optional - defaults to https://clob.polymarket.com
# CLOB_API_URL=https://clob.polymarket.com
```

### Setup Steps

1. **Get Your Wallet Private Key** (for L1 authentication):
   - Export your wallet's private key from MetaMask or your wallet
   - Add it to `.env` as `WALLET_PRIVATE_KEY`

2. **Create API Keys** (for L2 authentication - recommended):
   - Start your agent: `elizaos dev`
   - Ask your agent: "create an api key for polymarket"
   - Copy the returned credentials (key, secret, passphrase)
   - Add them to `.env` as `CLOB_API_KEY`, `CLOB_API_SECRET`, `CLOB_API_PASSPHRASE`
   - Restart your agent

## 🚀 Available Actions

Your agent can now perform the following Polymarket actions:

### Market Information
- **RETRIEVE_ALL_MARKETS** - Get all available markets
- **GET_SIMPLIFIED_MARKETS** - Get simplified market data
- **GET_MARKET_DETAILS** - Get detailed information about a specific market
- **GET_ORDER_BOOK_SUMMARY** - Get order book summary
- **GET_ORDER_BOOK_DEPTH** - Get full order book depth
- **GET_BEST_PRICE** - Get best bid/ask prices
- **GET_MIDPOINT_PRICE** - Get midpoint price
- **GET_SPREAD** - Get bid-ask spread
- **GET_PRICE_HISTORY** - Get historical price data

### Trading Operations
- **PLACE_ORDER** - Place buy/sell orders
- **GET_ACTIVE_ORDERS** - View active orders
- **GET_ORDER_DETAILS** - Get details of a specific order
- **GET_TRADE_HISTORY** - View trading history
- **CHECK_ORDER_SCORING** - Check order scoring status

### API Key Management
- **CREATE_API_KEY** - Create new API credentials
- **GET_API_KEYS** - List all API keys
- **REVOKE_API_KEY** - Revoke an API key

### Account & Authentication
- **GET_ACCOUNT_ACCESS_STATUS** - Check account access
- **HANDLE_AUTHENTICATION** - Handle authentication flow
- **SETUP_WEBSOCKET** - Set up real-time updates
- **HANDLE_REALTIME_UPDATES** - Handle real-time market updates

## 💬 Example Usage

Once configured, you can interact with your agent like this:

```
You: "What are the top prediction markets on Polymarket?"
Agent: [Retrieves and displays market information]

You: "Get details for the market about [topic]"
Agent: [Shows detailed market information]

You: "Create an API key for polymarket"
Agent: [Creates and returns API credentials]

You: "Show me the order book for [market]"
Agent: [Displays order book data]

You: "Place a buy order for [market] at [price]"
Agent: [Places the order if authenticated]
```

## 🔒 Security Notes

- **Never commit your `.env` file** - It contains sensitive private keys
- **Keep your private keys secure** - Anyone with your private key can control your wallet
- **Use API keys for trading** - More secure than using wallet private keys directly
- **Revoke unused API keys** - Regularly audit and revoke unused credentials

## 📚 Documentation

- **Plugin Repository**: https://github.com/elizaOS-plugins/plugin-polymarket
- **Polymarket API Docs**: https://docs.polymarket.com/developers/CLOB/introduction
- **CLOB Client**: https://github.com/Polymarket/clob-client

## 🐛 Troubleshooting

### Plugin not loading?
- Check that the plugin is imported in `src/index.ts`
- Verify all dependencies are installed: `bun install`
- Rebuild the project: `bun run build`

### Authentication errors?
- Verify `WALLET_PRIVATE_KEY` is set correctly
- For API operations, ensure `CLOB_API_KEY`, `CLOB_API_SECRET`, and `CLOB_API_PASSPHRASE` are set
- Create API keys using the CREATE_API_KEY action if needed

### Actions not working?
- Check that environment variables are loaded (restart agent after changing .env)
- Verify your wallet has sufficient balance for trading operations
- Check the agent logs for specific error messages

## ✨ Next Steps

1. **Configure your wallet**: Add `WALLET_PRIVATE_KEY` to `.env`
2. **Start the agent**: `elizaos dev`
3. **Create API keys**: Ask your agent to create API keys
4. **Test market queries**: Try asking about markets
5. **Explore trading**: Once authenticated, try placing orders

Your agent is now ready to interact with Polymarket prediction markets! 🎉
