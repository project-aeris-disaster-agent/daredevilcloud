import type { Plugin } from '@elizaos/core';
import {
  type Action,
  type Content,
  type GenerateTextParams,
  type HandlerCallback,
  type IAgentRuntime,
  type Memory,
  ModelType,
  type Provider,
  type ProviderResult,
  Service,
  type State,
  logger,
} from '@elizaos/core';
import { z } from 'zod';
import { retrieveAllMarketsAction } from './actions/retrieveAllMarkets';
import { getSimplifiedMarketsAction } from './actions/getSimplifiedMarkets';
import { getMarketDetailsAction } from './actions/getMarketDetails';
import { getOrderBookSummaryAction } from './actions/getOrderBookSummary';
import { getOrderBookDepthAction } from './actions/getOrderBookDepth';
import { getBestPriceAction } from './actions/getBestPrice';
import { getMidpointPriceAction } from './actions/getMidpointPrice';
import { getSpreadAction } from './actions/getSpread';
import { getSamplingMarkets } from './actions/getSamplingMarkets';
import { getClobMarkets } from './actions/getClobMarkets';
import { getOpenMarkets } from './actions/getOpenMarkets';
import { getPriceHistory } from './actions/getPriceHistory';
import { placeOrderAction } from './actions/placeOrder';
import { createApiKeyAction } from './actions/createApiKey';
import { revokeApiKeyAction } from './actions/revokeApiKey';
import { getAllApiKeysAction } from './actions/getAllApiKeys';
import { getOrderDetailsAction } from './actions/getOrderDetails';
import { checkOrderScoringAction } from './actions/checkOrderScoring';
import { getActiveOrdersAction } from './actions/getActiveOrders';
import { getAccountAccessStatusAction } from './actions/getAccountAccessStatus';
import { getTradeHistoryAction } from './actions/getTradeHistory';
import { handleAuthenticationAction } from './actions/handleAuthentication';
import { setupWebsocketAction } from './actions/setupWebsocket';
import { handleRealtimeUpdatesAction } from './actions/handleRealtimeUpdates';

/**
 * Helper to convert empty strings to undefined for optional fields
 */
const optionalString = (fieldName: string, warningMessage?: string) =>
  z.preprocess(
    (val) => (val === '' || val === null ? undefined : val),
    z
      .string()
      .min(1)
      .optional()
      .transform((val) => {
        if (!val && warningMessage) {
          console.warn(`Warning: ${fieldName} not provided, ${warningMessage}`);
        }
        return val;
      })
  );

/**
 * Define the configuration schema for the Polymarket plugin
 * All fields are optional to allow the plugin to initialize without credentials.
 * Trading/API features will be disabled if credentials are not provided.
 */
const configSchema = z.object({
  CLOB_API_URL: z.preprocess(
    (val) => (val === '' || val === null ? undefined : val),
    z
      .string()
      .url('CLOB API URL must be a valid URL')
      .optional()
      .default('https://clob.polymarket.com')
  ),
  WALLET_PRIVATE_KEY: optionalString('WALLET_PRIVATE_KEY', 'trading features will be disabled'),
  PRIVATE_KEY: optionalString('PRIVATE_KEY', 'will use WALLET_PRIVATE_KEY instead'),
  CLOB_API_KEY: optionalString('CLOB_API_KEY', 'using wallet-based authentication'),
  CLOB_API_SECRET: optionalString('CLOB_API_SECRET', 'API authentication disabled'),
  CLOB_API_PASSPHRASE: optionalString('CLOB_API_PASSPHRASE', 'API authentication disabled'),
  POLYMARKET_PRIVATE_KEY: optionalString('POLYMARKET_PRIVATE_KEY', 'will use WALLET_PRIVATE_KEY instead'),
});

/**
 * Polymarket Service for managing CLOB connections and state
 */
export class PolymarketService extends Service {
  static serviceType = 'polymarket';
  capabilityDescription =
    'This service provides access to Polymarket prediction markets through the CLOB API.';

  constructor(runtime: IAgentRuntime) {
    super(runtime);
  }

  static async start(runtime: IAgentRuntime) {
    logger.info('*** Starting Polymarket service ***');
    const service = new PolymarketService(runtime);
    return service;
  }

  static async stop(runtime: IAgentRuntime) {
    logger.info('*** Stopping Polymarket service ***');
    const service = runtime.getService(PolymarketService.serviceType);
    if (!service) {
      throw new Error('Polymarket service not found');
    }
    service.stop();
  }

  async stop() {
    logger.info('*** Stopping Polymarket service instance ***');
  }
}

/**
 * Example provider for Polymarket market data
 */
const polymarketProvider: Provider = {
  name: 'POLYMARKET_PROVIDER',
  description: 'Provides current Polymarket market information and context',

  get: async (runtime: IAgentRuntime, message: Memory, state: State): Promise<ProviderResult> => {
    try {
      const clobApiUrl = runtime.getSetting('CLOB_API_URL') || 'https://clob.polymarket.com';

      return {
        text: `Connected to Polymarket CLOB at ${clobApiUrl}. Ready to fetch market data and execute trades.`,
        values: {
          clobApiUrl,
          serviceStatus: 'active',
          featuresAvailable: ['market_data', 'price_feeds', 'order_book'],
        },
        data: {
          timestamp: new Date().toISOString(),
          service: 'polymarket',
        },
      };
    } catch (error) {
      logger.error('Error in Polymarket provider:', error);
      return {
        text: 'Polymarket service is currently unavailable.',
        values: {
          serviceStatus: 'error',
          error: error instanceof Error ? error.message : 'Unknown error',
        },
        data: {
          timestamp: new Date().toISOString(),
          service: 'polymarket',
        },
      };
    }
  },
};

const plugin: Plugin = {
  name: 'polymarket',
  description: 'A plugin for interacting with Polymarket prediction markets',
  config: {
    CLOB_API_URL: process.env.CLOB_API_URL,
    WALLET_PRIVATE_KEY: process.env.WALLET_PRIVATE_KEY,
    PRIVATE_KEY: process.env.PRIVATE_KEY,
    CLOB_API_KEY: process.env.CLOB_API_KEY,
    CLOB_API_SECRET: process.env.CLOB_API_SECRET,
    CLOB_API_PASSPHRASE: process.env.CLOB_API_PASSPHRASE,
    POLYMARKET_PRIVATE_KEY: process.env.POLYMARKET_PRIVATE_KEY,
  },
  async init(config: Record<string, string>) {
    logger.info('*** Initializing Polymarket plugin ***');
    try {
      const validatedConfig = await configSchema.parseAsync(config);

      // Set all environment variables at once
      for (const [key, value] of Object.entries(validatedConfig)) {
        if (value) process.env[key] = value;
      }

      logger.info('Polymarket plugin initialized successfully');
    } catch (error) {
      if (error instanceof z.ZodError) {
        // Zod v3+ uses .issues not .errors
        const issues = error.issues || [];
        throw new Error(
          `Invalid Polymarket plugin configuration: ${issues.map((e) => e.message).join(', ')}`
        );
      }
      throw error;
    }
  },
  services: [PolymarketService],
  actions: [
    retrieveAllMarketsAction,
    getSimplifiedMarketsAction,
    getSamplingMarkets,
    getClobMarkets,
    getOpenMarkets,
    getPriceHistory,
    getMarketDetailsAction,
    getOrderBookSummaryAction,
    getOrderBookDepthAction,
    getBestPriceAction,
    getMidpointPriceAction,
    getSpreadAction,
    placeOrderAction,
    createApiKeyAction,
    revokeApiKeyAction,
    getAllApiKeysAction,
    getOrderDetailsAction,
    checkOrderScoringAction,
    getActiveOrdersAction,
    getAccountAccessStatusAction,
    getTradeHistoryAction,
    handleAuthenticationAction,
    setupWebsocketAction,
    handleRealtimeUpdatesAction,
  ],
  providers: [polymarketProvider],
};

export default plugin;
