import { logger, type IAgentRuntime, type Project, type ProjectAgent } from '@elizaos/core';
import starterPlugin from './plugin.ts';
import polymarketPlugin from './plugins/polymarket/plugin.ts';
import { character } from './character.ts';

const initCharacter = ({ runtime }: { runtime: IAgentRuntime }) => {
  logger.info('Initializing character');
  logger.info({ name: character.name }, 'Name:');
  
  // #region agent log
  fetch('http://host.docker.internal:7243/ingest/cb646961-d10e-4363-8df1-8af6af43b643',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'index.ts:9',message:'Character init - checking runtime models',data:{pluginCount:character.plugins.length,plugins:character.plugins},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'B'})}).catch(()=>{});
  // #endregion
  
  // #region agent log
  const hasTextLarge = runtime.models && typeof runtime.models['TEXT_LARGE'] === 'function';
  fetch('http://host.docker.internal:7243/ingest/cb646961-d10e-4363-8df1-8af6af43b643',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({location:'index.ts:15',message:'Runtime TEXT_LARGE handler check',data:{hasTextLarge,modelTypes:runtime.models?Object.keys(runtime.models):[]},timestamp:Date.now(),sessionId:'debug-session',runId:'run1',hypothesisId:'A'})}).catch(()=>{});
  // #endregion
};

// Create Daredevil character using the same working configuration as Eliza
const daredevilCharacter = {
  ...character,
  name: 'Daredevil',
  // Keep all the same plugins and settings that make Eliza work
};

export const projectAgent: ProjectAgent = {
  character,
  init: async (runtime: IAgentRuntime) => await initCharacter({ runtime }),
  plugins: [polymarketPlugin], // Polymarket plugin for prediction markets
};

// Daredevil agent with same working configuration
export const daredevilAgent: ProjectAgent = {
  character: daredevilCharacter,
  init: async (runtime: IAgentRuntime) => await initCharacter({ runtime }),
  plugins: [polymarketPlugin], // Polymarket plugin for prediction markets
};

const project: Project = {
  agents: [projectAgent, daredevilAgent], // Both agents use the same working config
};

export { character } from './character.ts';

export default project;
