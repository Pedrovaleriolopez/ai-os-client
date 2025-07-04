# 🚀 AI-OS Client Setup Guide

## Guia completo para configurar seu ambiente de desenvolvimento e conectar ao AI-OS

### 📥 Para Iniciantes: Veja o [QUICK START](../QUICK_START.md) primeiro!

### Pré-requisitos

- **Windsurf** (com Cascade AI) ou **Claude Desktop** instalado
- **Git** instalado
- **Node.js 18+** (opcional, para desenvolvimento local)
- **WSL** (Windows Subsystem for Linux) se estiver no Windows

---

## 📋 Passo 1: Clonar Repositório

```bash
# Clone o repositório AI-OS Client
git clone https://github.com/allfluencee/ai-os-client.git
cd ai-os-client
```

## 🔐 Passo 2: Registrar ou Fazer Login

### Windows (PowerShell)
```powershell
# Execute o script de registro
./scripts/register-user.ps1

# Escolha:
# 1 - Para criar nova conta
# 2 - Para fazer login com conta existente
```

### Mac/Linux
```bash
# Execute o script de registro
chmod +x scripts/register-user.sh
./scripts/register-user.sh

# Escolha:
# 1 - Para criar nova conta
# 2 - Para fazer login com conta existente
```

**Importante**: O script salvará suas credenciais em `.ai-os-credentials.json` para uso futuro.

## 🔧 Passo 3: Executar Setup Automático

### Windows (PowerShell)
```powershell
# Execute o script de setup
./scripts/setup-client.ps1

# O script irá:
# ✅ Carregar credenciais salvas automaticamente
# ✅ Configurar SSH se necessário
# ✅ Criar arquivos de configuração MCP
# ✅ Testar conexão com os serviços
```

### Mac/Linux
```bash
# Execute o script de setup
chmod +x scripts/setup-client.sh
./scripts/setup-client.sh

# O script irá:
# ✅ Carregar credenciais salvas automaticamente
# ✅ Configurar SSH se necessário
# ✅ Criar arquivos de configuração MCP
# ✅ Testar conexão com os serviços
```

## 🚀 Passo 4: Abrir no IDE

### Para Windsurf (Recomendado)
```bash
windsurf .
```

**Configurando o Cascade no Windsurf:**
1. Pressione `Ctrl+Shift+P` (Windows) ou `Cmd+Shift+P` (Mac)
2. Digite: `Windsurf: Sign in`
3. Faça login com sua conta do Windsurf/Codeium
4. Use `Ctrl+L` ou `Cmd+L` para abrir o Cascade

**Importante para Windows**: Use o terminal WSL no Windsurf!
- Abra o terminal: `Ctrl+` ` (backtick)
- Clique no dropdown `+` → Selecione "WSL" ou "Ubuntu"

### Para Claude Desktop
```bash
# Configure no Claude Desktop seguindo as instruções da interface
```

Os MCPs serão carregados automaticamente quando você abrir o projeto.

## 🧪 Passo 5: Testar Conexão

### Teste automático
```javascript
// Execute no Cascade/Claude
node test-mcps.js
```

### Teste manual
```javascript
// Testar Orchestrator
const workflows = await orchestrator.listWorkflows();
console.log(workflows);

// Testar Memory Hub
await memory.store("test-key", { hello: "world" });
const data = await memory.retrieve("test-key");
console.log(data);
```

## 📚 Uso Diário

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

### Windows: "WSL não está instalado"
```powershell
# Execute no PowerShell como Admin:
wsl --install
# Reinicie o computador após a instalação
```

### Erro: "Credenciais não encontradas"
```bash
# Execute o script de registro novamente
./scripts/register-user.ps1  # ou .sh
```

### Erro: "SSH connection refused"
```bash
# O script de setup tentará configurar SSH automaticamente
# Se falhar, adicione manualmente sua chave pública ao servidor:

# 1. Copie sua chave pública
cat ~/.ssh/id_rsa.pub

# 2. Adicione ao servidor
ssh root@5.161.112.59 "echo 'SUA_CHAVE_PUBLICA' >> ~/.ssh/authorized_keys"
```

### Erro: "MCP not responding"
```bash
# Verificar se os containers estão rodando
ssh root@5.161.112.59 "docker ps | grep -E '(orchestrator|memory|context|graph)'"

# Reiniciar serviços se necessário
ssh root@5.161.112.59 "docker-compose -f /path/to/compose.yml restart"
```

### Erro: "Authentication failed"
```bash
# Execute o script de registro para renovar token
./scripts/register-user.ps1  # ou .sh

# Escolha opção 2 (login) e entre com suas credenciais
```

## 🤖 Desenvolvimento de Agentes

Consulte o [Guia de Desenvolvimento de Agentes](AGENT_DEVELOPMENT_GUIDE.md) para:
- Criar agentes customizados
- Integrar com o AI-OS Framework
- Exemplos completos de implementação

## 📱 Suporte

- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Email**: support@allfluence.ai
- **Docs**: https://docs.allfluence.ai
- **Issues**: [GitHub Issues](https://github.com/allfluencee/ai-os-client/issues)

---

**Versão**: 1.2.0  
**Última atualização**: 04/01/2025