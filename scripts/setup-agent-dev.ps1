# 🤖 AI-OS Agent Development Setup Script (PowerShell)
# Configura ambiente para desenvolvimento de agentes

Write-Host "🤖 AI-OS Agent Development Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Node.js
Write-Host "📋 Verificando pré-requisitos..." -ForegroundColor Yellow
try {
    $nodeVersion = node -v
    $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    
    if ($versionNumber -lt 18) {
        Write-Host "❌ Node.js 18+ é necessário. Versão atual: $nodeVersion" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Node.js $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js não encontrado. Por favor, instale Node.js 18+" -ForegroundColor Red
    exit 1
}

# Criar estrutura do projeto
Write-Host ""
Write-Host "📁 Criando estrutura do projeto..." -ForegroundColor Yellow
$AGENT_NAME = Read-Host "Nome do seu agente"
$AGENT_DIR = $AGENT_NAME.ToLower().Replace(' ', '-')

New-Item -ItemType Directory -Path $AGENT_DIR -Force | Out-Null
Set-Location $AGENT_DIR

# Criar diretórios
New-Item -ItemType Directory -Path "src", "tests", "docs" -Force | Out-Null

# Copiar templates
Write-Host "📋 Copiando templates..." -ForegroundColor Yellow
if (Test-Path "../templates/package.json") {
    Copy-Item "../templates/package.json" -Destination "."
} else {
    @"
{
  "name": "$($AGENT_DIR)",
  "version": "1.0.0",
  "description": "$AGENT_NAME - AI Agent for AI-OS",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest"
  },
  "dependencies": {
    "@ai-os/agent-framework": "^1.0.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "typescript": "^5.3.3",
    "tsx": "^4.7.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1"
  }
}
"@ | Out-File -FilePath "package.json" -Encoding UTF8
}

# Criar tsconfig.json
@"
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
"@ | Out-File -FilePath "tsconfig.json" -Encoding UTF8

# Criar .env.local
$envContent = @"
# Agent Configuration
AGENT_NAME=$AGENT_NAME
NODE_ENV=development

"@

# Copiar variáveis do .env.local pai se existir
if (Test-Path "../.env.local") {
    $parentEnv = Get-Content "../.env.local" | Where-Object { 
        $_ -match "USER_ID|USER_EMAIL|TENANT_ID|API_GATEWAY_URL|ORCHESTRATOR_URL|MEMORY_HUB_URL" 
    }
    $envContent += "`n# AI-OS Connection`n"
    $envContent += ($parentEnv -join "`n")
} else {
    $envContent += "`n# Configure as variáveis do AI-OS`n"
    $envContent += "# USER_ID=`n# USER_EMAIL=`n# TENANT_ID=`n"
}

$envContent | Out-File -FilePath ".env.local" -Encoding UTF8

# Criar agente exemplo
@'
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
'@ | Out-File -FilePath "src\index.ts" -Encoding UTF8

# Criar teste exemplo
@'
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
'@ | Out-File -FilePath "tests\agent.test.ts" -Encoding UTF8

# Criar jest.config.js
@'
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
'@ | Out-File -FilePath "jest.config.js" -Encoding UTF8

# Criar README
@"
# $AGENT_NAME

AI Agent desenvolvido para AI-OS.

## 🚀 Quick Start

```bash
# Instalar dependências
npm install

# Desenvolvimento
npm run dev

# Build
npm run build

# Testes
npm test
```

## 📚 Documentação

- [AI-OS Agent Framework](https://docs.allfluence.ai/agent-framework)
- [Guia de Desenvolvimento](../docs/AGENT_DEVELOPMENT_GUIDE.md)

## 📄 Licença

MIT
"@ | Out-File -FilePath "README.md" -Encoding UTF8

# Instalar dependências
Write-Host ""
Write-Host "📦 Instalando dependências..." -ForegroundColor Yellow
npm install

Write-Host ""
Write-Host "✅ Setup concluído!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. cd $AGENT_DIR"
Write-Host "2. Edite src\index.ts para implementar seu agente"
Write-Host "3. npm run dev para desenvolvimento"
Write-Host "4. npm test para executar testes"
Write-Host ""
Write-Host "💡 Dica: Use 'code .' ou 'windsurf .' para abrir no editor" -ForegroundColor Cyan
Write-Host ""