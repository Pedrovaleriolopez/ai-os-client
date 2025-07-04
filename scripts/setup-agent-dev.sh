#!/bin/bash

# 🤖 AI-OS Agent Development Setup Script
# Configura ambiente para desenvolvimento de agentes

set -e

echo "🤖 AI-OS Agent Development Setup"
echo "================================"
echo ""

# Verificar Node.js
echo "📋 Verificando pré-requisitos..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não encontrado. Por favor, instale Node.js 18+"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js 18+ é necessário. Versão atual: $(node -v)"
    exit 1
fi
echo "✅ Node.js $(node -v)"

# Criar estrutura do projeto
echo ""
echo "📁 Criando estrutura do projeto..."
read -p "Nome do seu agente: " AGENT_NAME
AGENT_DIR=$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

mkdir -p "$AGENT_DIR"
cd "$AGENT_DIR"

# Criar diretórios
mkdir -p src tests docs

# Copiar templates
echo "📋 Copiando templates..."
cp ../templates/package.json .
cp ../templates/tsconfig.json . 2>/dev/null || cat > tsconfig.json << 'EOF'
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
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF

# Criar .env.local
cat > .env.local << EOF
# Agent Configuration
AGENT_NAME=$AGENT_NAME
NODE_ENV=development

# AI-OS Connection (from parent .env.local)
$(grep -E "USER_ID|USER_EMAIL|TENANT_ID|API_GATEWAY_URL|ORCHESTRATOR_URL|MEMORY_HUB_URL" ../.env.local 2>/dev/null || echo "# Configure as variáveis do AI-OS")
EOF

# Criar agente exemplo
cat > src/index.ts << 'EOF'
import { Agent, AgentConfig, AgentManager } from '@ai-os/agent-framework';
import { z } from 'zod';

// Definir schema de configuração
const ConfigSchema = z.object({
  name: z.string(),
  description: z.string().optional(),
  model: z.string().default('gpt-4'),
  temperature: z.number().min(0).max(2).default(0.7)
});

type MyAgentConfig = z.infer<typeof ConfigSchema>;

// Implementar agente
export class MyAgent extends Agent<MyAgentConfig> {
  async initialize(): Promise<void> {
    await this.initializeTools(['memory', 'web-search']);
    this.logger.info('Agent initialized');
  }

  async execute(input: any): Promise<any> {
    this.logger.debug('Processing input', { input });
    
    // Implementar lógica do agente aqui
    const result = {
      success: true,
      message: `Processed: ${JSON.stringify(input)}`,
      timestamp: new Date().toISOString()
    };
    
    return result;
  }
}

// Exemplo de uso
async function main() {
  const manager = new AgentManager();
  
  const agent = await manager.create({
    type: MyAgent,
    config: {
      name: process.env.AGENT_NAME || 'My Agent',
      description: 'A custom AI agent'
    }
  });
  
  const result = await agent.execute({
    action: 'test',
    data: 'Hello AI-OS!'
  });
  
  console.log('Result:', result);
}

if (require.main === module) {
  main().catch(console.error);
}
EOF

# Criar teste exemplo
cat > tests/agent.test.ts << 'EOF'
import { describe, test, expect } from '@jest/globals';
import { MyAgent } from '../src';

describe('MyAgent', () => {
  let agent: MyAgent;

  beforeEach(async () => {
    agent = new MyAgent({
      name: 'Test Agent',
      model: 'gpt-4',
      temperature: 0.5
    });
    await agent.initialize();
  });

  test('should process input correctly', async () => {
    const result = await agent.execute({
      action: 'test',
      data: 'test data'
    });

    expect(result.success).toBe(true);
    expect(result.message).toContain('test data');
  });

  afterEach(async () => {
    await agent.terminate();
  });
});
EOF

# Criar jest.config.js
cat > jest.config.js << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts'
  ]
};
EOF

# Criar README
cat > README.md << EOF
# $AGENT_NAME

AI Agent desenvolvido para AI-OS.

## 🚀 Quick Start

\`\`\`bash
# Instalar dependências
npm install

# Desenvolvimento
npm run dev

# Build
npm run build

# Testes
npm test
\`\`\`

## 📚 Documentação

- [AI-OS Agent Framework](https://docs.allfluence.ai/agent-framework)
- [Guia de Desenvolvimento](../docs/AGENT_DEVELOPMENT_GUIDE.md)

## 📄 Licença

MIT
EOF

# Instalar dependências
echo ""
echo "📦 Instalando dependências..."
npm install

echo ""
echo "✅ Setup concluído!"
echo ""
echo "📋 Próximos passos:"
echo "1. cd $AGENT_DIR"
echo "2. Edite src/index.ts para implementar seu agente"
echo "3. npm run dev para desenvolvimento"
echo "4. npm test para executar testes"
echo ""
echo "💡 Dica: Use 'code .' ou 'windsurf .' para abrir no editor"
echo ""