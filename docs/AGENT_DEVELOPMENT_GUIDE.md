# 🤖 Agent Development Guide for AI-OS

## Como criar e executar agentes localmente usando o AI-OS Framework

### 📋 Pré-requisitos

1. **Conexão com AI-OS configurada** (veja [CLIENT_SETUP_GUIDE.md](./CLIENT_SETUP_GUIDE.md))
2. **Node.js 18+** instalado localmente
3. **TypeScript** conhecimento básico

### 🚀 Quick Start - Criando seu Primeiro Agente

#### 1. Instalar o Agent Framework

```bash
# Criar novo projeto
mkdir meu-agente-ai
cd meu-agente-ai
npm init -y

# Instalar dependências
npm install @ai-os/agent-framework zod
npm install -D typescript @types/node tsx
```

#### 2. Configurar TypeScript

Criar `tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

#### 3. Criar Estrutura do Projeto

```bash
mkdir src
touch src/meu-agente.ts
touch src/index.ts
```

### 💻 Exemplo Completo: Agente de Análise de Sentimentos

#### `src/sentiment-agent.ts`

```typescript
import { Agent, AgentConfig } from '@ai-os/agent-framework';
import { z } from 'zod';

// Schema de configuração
const SentimentAgentConfigSchema = z.object({
  language: z.enum(['pt', 'en', 'es']).default('pt'),
  model: z.string().default('gpt-4'),
  sensitivity: z.enum(['low', 'medium', 'high']).default('medium'),
  includeEmotions: z.boolean().default(true)
});

type SentimentAgentConfig = z.infer<typeof SentimentAgentConfigSchema>;

// Schema de entrada/saída
const InputSchema = z.object({
  text: z.string().min(1),
  context: z.string().optional()
});

const OutputSchema = z.object({
  sentiment: z.enum(['positive', 'negative', 'neutral', 'mixed']),
  score: z.number().min(-1).max(1),
  confidence: z.number().min(0).max(1),
  emotions: z.array(z.object({
    emotion: z.string(),
    intensity: z.number()
  })).optional(),
  explanation: z.string()
});

// Implementação do Agente
export class SentimentAnalysisAgent extends Agent<SentimentAgentConfig> {
  constructor(config: SentimentAgentConfig) {
    super(config);
    this.validateConfig();
  }

  private validateConfig() {
    SentimentAgentConfigSchema.parse(this.config);
  }

  async initialize(): Promise<void> {
    // Inicializar ferramentas MCP necessárias
    await this.initializeTools(['text-analyzer', 'emotion-detector']);
    
    // Conectar com Memory Hub para cache
    await this.memory.connect();
    
    this.logger.info('Sentiment Analysis Agent initialized', {
      language: this.config.language,
      model: this.config.model
    });
  }

  async execute(input: unknown): Promise<z.infer<typeof OutputSchema>> {
    // Validar entrada
    const { text, context } = InputSchema.parse(input);
    
    try {
      // Verificar cache
      const cacheKey = `sentiment:${this.hash(text)}`;
      const cached = await this.memory.get(cacheKey);
      if (cached) {
        this.logger.debug('Returning cached result');
        return cached;
      }

      // Analisar sentimento
      const analysis = await this.analyzeSentiment(text, context);
      
      // Detectar emoções se configurado
      let emotions;
      if (this.config.includeEmotions) {
        emotions = await this.detectEmotions(text);
      }

      // Preparar resultado
      const result = {
        sentiment: analysis.sentiment,
        score: analysis.score,
        confidence: analysis.confidence,
        emotions,
        explanation: this.generateExplanation(analysis, emotions)
      };

      // Salvar no cache
      await this.memory.set(cacheKey, result, { ttl: 3600 });

      return result;
    } catch (error) {
      this.logger.error('Failed to analyze sentiment', error);
      throw error;
    }
  }

  private async analyzeSentiment(text: string, context?: string) {
    const prompt = this.buildPrompt(text, context);
    
    const response = await this.llm.generate({
      prompt,
      model: this.config.model,
      temperature: 0.3,
      responseFormat: {
        type: 'json_object',
        schema: {
          sentiment: 'string',
          score: 'number',
          confidence: 'number',
          reasoning: 'string'
        }
      }
    });

    return JSON.parse(response);
  }

  private async detectEmotions(text: string) {
    const emotions = await this.tools.use('emotion-detector', {
      text,
      language: this.config.language,
      threshold: this.config.sensitivity === 'high' ? 0.3 : 0.5
    });

    return emotions.map(e => ({
      emotion: e.name,
      intensity: e.score
    }));
  }

  private buildPrompt(text: string, context?: string): string {
    const lang = {
      pt: 'português',
      en: 'English',
      es: 'español'
    }[this.config.language];

    return `
Analyze the sentiment of the following text in ${lang}.

Text: "${text}"
${context ? `Context: "${context}"` : ''}

Provide your analysis in JSON format with:
- sentiment: "positive", "negative", "neutral", or "mixed"
- score: -1 (most negative) to 1 (most positive)
- confidence: 0 to 1
- reasoning: brief explanation

Be sensitive to nuances and cultural context.
    `.trim();
  }

  private generateExplanation(analysis: any, emotions?: any[]): string {
    const templates = {
      pt: {
        positive: 'O texto expressa sentimentos positivos',
        negative: 'O texto expressa sentimentos negativos',
        neutral: 'O texto é neutro, sem sentimento claro',
        mixed: 'O texto contém sentimentos mistos'
      },
      en: {
        positive: 'The text expresses positive feelings',
        negative: 'The text expresses negative feelings',
        neutral: 'The text is neutral with no clear sentiment',
        mixed: 'The text contains mixed feelings'
      },
      es: {
        positive: 'El texto expresa sentimientos positivos',
        negative: 'El texto expresa sentimientos negativos',
        neutral: 'El texto es neutral, sin sentimiento claro',
        mixed: 'El texto contiene sentimientos mixtos'
      }
    };

    let explanation = templates[this.config.language][analysis.sentiment];
    
    if (emotions && emotions.length > 0) {
      const topEmotion = emotions[0];
      explanation += ` (${topEmotion.emotion}: ${Math.round(topEmotion.intensity * 100)}%)`;
    }

    return explanation;
  }

  private hash(text: string): string {
    // Simple hash for cache key
    return Buffer.from(text).toString('base64').substring(0, 16);
  }

  async terminate(): Promise<void> {
    await this.memory.disconnect();
    await super.terminate();
  }
}
```

#### `src/index.ts` - Usando o Agente

```typescript
import { AgentManager } from '@ai-os/agent-framework';
import { SentimentAnalysisAgent } from './sentiment-agent';

async function main() {
  // Criar gerenciador de agentes
  const manager = new AgentManager({
    mcpEndpoint: process.env.ORCHESTRATOR_URL || 'https://orchestrator.allfluence.ai',
    userId: process.env.USER_ID,
    tenantId: process.env.TENANT_ID || 'default'
  });

  // Registrar tipo de agente
  manager.registerType('sentiment-analyzer', SentimentAnalysisAgent);

  // Criar instância
  const agent = await manager.create({
    name: 'Meu Analisador de Sentimentos',
    type: 'sentiment-analyzer',
    config: {
      language: 'pt',
      model: 'gpt-4',
      sensitivity: 'high',
      includeEmotions: true
    }
  });

  // Exemplos de uso
  const textos = [
    "Estou muito feliz com o resultado do projeto!",
    "O atendimento foi péssimo, estou decepcionado.",
    "O produto funciona conforme esperado.",
    "Amei a experiência, mas o preço está um pouco alto."
  ];

  for (const texto of textos) {
    console.log(`\n📝 Analisando: "${texto}"`);
    
    const resultado = await agent.execute({ text: texto });
    
    console.log(`😊 Sentimento: ${resultado.sentiment}`);
    console.log(`📊 Score: ${resultado.score.toFixed(2)}`);
    console.log(`✅ Confiança: ${(resultado.confidence * 100).toFixed(0)}%`);
    console.log(`💭 ${resultado.explanation}`);
    
    if (resultado.emotions) {
      console.log('🎭 Emoções detectadas:');
      resultado.emotions.forEach(e => {
        console.log(`   - ${e.emotion}: ${(e.intensity * 100).toFixed(0)}%`);
      });
    }
  }

  // Limpar recursos
  await agent.terminate();
}

// Executar
main().catch(console.error);
```

### 🧪 Testando seu Agente

#### `src/sentiment-agent.test.ts`

```typescript
import { describe, test, expect, beforeEach } from '@jest/globals';
import { SentimentAnalysisAgent } from './sentiment-agent';
import { MockAgentTools } from '@ai-os/testing';

describe('SentimentAnalysisAgent', () => {
  let agent: SentimentAnalysisAgent;
  let mockTools: MockAgentTools;

  beforeEach(async () => {
    mockTools = new MockAgentTools();
    
    agent = new SentimentAnalysisAgent({
      language: 'pt',
      model: 'gpt-4',
      sensitivity: 'medium',
      includeEmotions: true
    });

    // Injetar mocks
    agent.tools = mockTools;
    await agent.initialize();
  });

  test('deve analisar sentimento positivo', async () => {
    mockTools.mockLLMResponse({
      sentiment: 'positive',
      score: 0.8,
      confidence: 0.9,
      reasoning: 'Expressa felicidade'
    });

    const result = await agent.execute({
      text: 'Estou muito feliz!'
    });

    expect(result.sentiment).toBe('positive');
    expect(result.score).toBeGreaterThan(0);
  });

  test('deve detectar emoções quando configurado', async () => {
    mockTools.mockToolResponse('emotion-detector', [
      { name: 'alegria', score: 0.9 },
      { name: 'entusiasmo', score: 0.7 }
    ]);

    const result = await agent.execute({
      text: 'Que notícia maravilhosa!'
    });

    expect(result.emotions).toBeDefined();
    expect(result.emotions).toHaveLength(2);
    expect(result.emotions[0].emotion).toBe('alegria');
  });
});
```

### 🚀 Executando o Agente

```bash
# Desenvolvimento
npm run dev

# Produção
npm run build
npm start

# Testes
npm test
```

### 📦 Publicando seu Agente

#### 1. Preparar para publicação

```json
// package.json
{
  "name": "@seu-usuario/sentiment-agent",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build"
  },
  "peerDependencies": {
    "@ai-os/agent-framework": "^1.0.0"
  }
}
```

#### 2. Publicar no registro AI-OS

```bash
# Login no registro privado
npm login --registry https://registry.allfluence.ai

# Publicar
npm publish --access public
```

### 🔧 Configurações Avançadas

#### Multi-Agente Colaborativo

```typescript
// Criar pipeline de agentes
const pipeline = manager.createPipeline([
  {
    name: 'Extrator de Texto',
    type: 'text-extractor',
    config: { format: 'markdown' }
  },
  {
    name: 'Analisador de Sentimentos',
    type: 'sentiment-analyzer',
    config: { language: 'pt' }
  },
  {
    name: 'Gerador de Relatório',
    type: 'report-generator',
    config: { template: 'sentiment-analysis' }
  }
]);

// Executar pipeline
const result = await pipeline.execute({
  url: 'https://example.com/reviews'
});
```

#### Agente com Estado Persistente

```typescript
export class StatefulAgent extends Agent {
  async execute(input: any) {
    // Recuperar estado anterior
    const state = await this.state.get('conversation') || [];
    
    // Processar com contexto
    const response = await this.process(input, state);
    
    // Atualizar estado
    state.push({ input, response, timestamp: Date.now() });
    await this.state.set('conversation', state);
    
    return response;
  }
}
```

### 📚 Recursos Adicionais

- [Exemplos de Agentes](./examples/)
- [API Reference](https://docs.allfluence.ai/agent-framework)
- [Best Practices](./best-practices.md)
- [Troubleshooting](./troubleshooting.md)

### 🆘 Suporte

- **Discord**: Canal #agent-development
- **Forum**: https://forum.allfluence.ai
- **Email**: dev-support@allfluence.ai