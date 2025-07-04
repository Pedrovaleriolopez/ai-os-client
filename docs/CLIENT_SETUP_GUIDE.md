# 🚀 AI-OS Client Setup Guide

## Guia completo para configurar seu ambiente de desenvolvimento e conectar ao AI-OS

### Pré-requisitos

- **Claude Code** ou **Windsurf** instalado
- **SSH** configurado com acesso ao servidor (5.161.112.59)
- **Git** instalado
- **Node.js 18+** (opcional, para desenvolvimento local)

---

## 📋 Passo 1: Clonar Repositório

```bash
# Clone o repositório AI-OS
git clone https://github.com/allfluencee/ai-os.git
cd ai-os

# Ou se já tem acesso direto:
git clone git@github.com:allfluencee/ai-os.git
cd ai-os
```

## 🔧 Passo 2: Configurar SSH

### Windows (PowerShell)
```powershell
# Criar chave SSH se não existir
ssh-keygen -t rsa -b 4096 -C "seu-email@allfluence.ai"

# Adicionar chave ao ssh-agent
ssh-add ~/.ssh/id_rsa

# Testar conexão
ssh root@5.161.112.59 "echo 'SSH funcionando!'"
```

### Mac/Linux
```bash
# Criar chave SSH se não existir
ssh-keygen -t rsa -b 4096 -C "seu-email@allfluence.ai"

# Adicionar chave ao ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Testar conexão
ssh root@5.161.112.59 "echo 'SSH funcionando!'"
```

## 🤖 Passo 3: Configurar MCPs

### 3.1 Criar arquivo `.mcp.json` na raiz do projeto:

```json
{
  "mcpServers": {
    "ai-os-orchestrator": {
      "command": "ssh",
      "args": [
        "root@5.161.112.59",
        "docker exec -i ai-os-orchestrator node /app/dist/mcp-server.js"
      ],
      "env": {
        "USER_ID": "seu-usuario-id",
        "USER_EMAIL": "seu-email@allfluence.ai"
      }
    },
    "global-memory-hub": {
      "command": "ssh",
      "args": [
        "root@5.161.112.59",
        "docker exec -i global-memory-hub node /app/dist/mcp-server.js"
      ],
      "env": {
        "USER_ID": "seu-usuario-id",
        "USER_EMAIL": "seu-email@allfluence.ai"
      }
    },
    "context-manager": {
      "command": "ssh",
      "args": [
        "root@5.161.112.59",
        "docker exec -i context-manager node /app/dist/mcp-server.js"
      ],
      "env": {
        "USER_ID": "seu-usuario-id",
        "USER_EMAIL": "seu-email@allfluence.ai"
      }
    },
    "document-graph": {
      "command": "ssh",
      "args": [
        "root@5.161.112.59",
        "docker exec -i document-graph-mcp node /app/dist/index.js"
      ],
      "env": {
        "USER_ID": "seu-usuario-id",
        "USER_EMAIL": "seu-email@allfluence.ai"
      }
    }
  }
}
```

### 3.2 Configurar variáveis de ambiente

Criar arquivo `.env.local`:
```env
# Identificação do usuário
USER_ID=seu-usuario-id
USER_EMAIL=seu-email@allfluence.ai
TENANT_ID=default

# Supabase (projeto principal)
NEXT_PUBLIC_SUPABASE_URL=https://goqtkwyiokmdixpahvoc.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdvcXRrd3lpb2ttZGl4cGFodm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NzM2MTcsImV4cCI6MjA2NjU0OTYxN30.4pgM8zQBA_J85yXHpn7Tu4WiAE6tylK5Kek8eB0rZFc

# API Gateway
API_GATEWAY_URL=https://api.allfluence.ai

# MCP Endpoints
ORCHESTRATOR_URL=https://orchestrator.allfluence.ai
MEMORY_HUB_URL=https://memory.allfluence.ai
```

## 🔐 Passo 4: Autenticação

### 4.1 Obter token de acesso:

```bash
# Via curl
curl -X POST https://api.allfluence.ai/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seu-email@allfluence.ai",
    "password": "sua-senha"
  }'

# Salvar o token retornado
export AI_OS_TOKEN="seu-token-jwt"
```

### 4.2 Configurar Claude Code/Windsurf

No Claude Code, adicionar ao `.claude/settings.json`:
```json
{
  "env": {
    "AI_OS_TOKEN": "seu-token-jwt",
    "USER_ID": "seu-usuario-id"
  }
}
```

## 🧪 Passo 5: Testar Conexão

### 5.1 Teste básico dos MCPs:

```bash
# Testar Orchestrator
curl https://orchestrator.allfluence.ai/health

# Testar Memory Hub
curl https://memory.allfluence.ai/health

# Testar via Claude Code (após abrir o projeto)
# Use os comandos MCP disponíveis
```

### 5.2 Teste de colaboração:

No Claude Code, execute:
```javascript
// Criar uma memória
await memory.store("projeto-x", {
  descrição: "Novo projeto de IA",
  criador: "seu-usuario-id",
  data: new Date()
});

// Recuperar memória
const data = await memory.retrieve("projeto-x");
console.log(data);
```

## 📚 Passo 6: Uso Diário

### Comandos MCP disponíveis:

```javascript
// Orchestrator
orchestrator.executeWorkflow("memory-sync")
orchestrator.listWorkflows()
orchestrator.getWorkflowStatus("workflow-id")

// Memory Hub
memory.store(key, value, metadata)
memory.retrieve(key)
memory.search(query)
memory.delete(key)

// Context Manager
context.analyze(filePath)
context.getProjectStructure()
context.findDependencies()

// Document Graph
graph.createNode(document)
graph.createRelation(from, to, type)
graph.query(cypher)
```

## 🐛 Troubleshooting

### Erro: "SSH connection refused"
```bash
# Verificar SSH config
ssh -v root@5.161.112.59

# Adicionar ao ~/.ssh/config
Host ai-os
  HostName 5.161.112.59
  User root
  IdentityFile ~/.ssh/id_rsa
```

### Erro: "MCP not responding"
```bash
# Verificar se os containers estão rodando
ssh root@5.161.112.59 "docker ps | grep -E '(orchestrator|memory|context|graph)'"

# Reiniciar serviços se necessário
ssh root@5.161.112.59 "docker service update --force ai-os-orchestrator"
```

### Erro: "Authentication failed"
```bash
# Renovar token
curl -X POST https://api.allfluence.ai/auth/refresh \
  -H "Authorization: Bearer $AI_OS_TOKEN"
```

## 📱 Suporte

- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Email**: support@allfluence.ai
- **Docs**: https://docs.allfluence.ai

---

**Versão**: 1.0.0  
**Última atualização**: 03/07/2025