# 🤝 AI-OS Collaboration Setup

> Setup rápido para começar a colaborar no AI-OS usando Claude Code ou Windsurf

## 🚀 Quick Start (5 minutos)

### 1. Clone o repositório
```bash
git clone https://github.com/allfluencee/ai-os-client.git
cd ai-os-client
```

### 2. Registre-se ou faça login

**Windows (PowerShell):**
```powershell
.\scripts\register-user.ps1
```

**Mac/Linux:**
```bash
chmod +x scripts/register-user.sh
./scripts/register-user.sh
```

### 3. Execute o script de setup

**Windows (PowerShell):**
```powershell
.\scripts\setup-client.ps1
```

**Mac/Linux:**
```bash
chmod +x scripts/setup-client.sh
./scripts/setup-client.sh
```

### 4. Abra no Claude Code/Windsurf
```bash
# Claude Code
claude .

# Windsurf
windsurf .
```

## ✅ Validação

Após abrir o projeto, teste os MCPs:

1. Abra o terminal integrado
2. Execute: `node test-mcps.js`
3. Você deve ver:
```
🧪 Testando MCPs do AI-OS...

1. Testando Orchestrator...
✅ Orchestrator: 4 workflows disponíveis

2. Testando Memory Hub...
✅ Memory Hub: Funcionando

3. Testando Context Manager...
✅ Context Manager: Funcionando

4. Testando Document Graph...
✅ Document Graph: Funcionando

✅ Teste concluído!
```

## 🔧 Comandos MCP Disponíveis

### Memory Hub
```javascript
// Armazenar dados
await memory.store("projeto-x", {
  descrição: "Novo sistema de IA",
  responsável: "João",
  status: "em desenvolvimento"
});

// Recuperar dados
const projeto = await memory.retrieve("projeto-x");

// Buscar por padrão
const projetos = await memory.search("sistema");

// Deletar dados
await memory.delete("projeto-x");
```

### Orchestrator
```javascript
// Listar workflows disponíveis
const workflows = await orchestrator.listWorkflows();

// Executar workflow
const result = await orchestrator.executeWorkflow("memory-sync");

// Verificar status
const status = await orchestrator.getWorkflowStatus("workflow-123");
```

### Context Manager
```javascript
// Analisar arquivo
const analysis = await context.analyze("src/app.js");

// Obter estrutura do projeto
const structure = await context.getProjectStructure();

// Encontrar dependências
const deps = await context.findDependencies("package.json");
```

### Document Graph
```javascript
// Criar nó de documento
await graph.createNode({
  id: "doc-123",
  title: "Arquitetura do Sistema",
  type: "documentation"
});

// Criar relação
await graph.createRelation("doc-123", "doc-456", "REFERENCES");

// Query Cypher
const docs = await graph.query(
  "MATCH (d:Document) WHERE d.type = 'documentation' RETURN d"
);
```

## 🐛 Troubleshooting

### Erro: "SSH permission denied"
1. Verifique se sua chave SSH foi adicionada ao servidor
2. Entre em contato com o admin para adicionar sua chave

### Erro: "MCP server not responding"
1. Verifique se está conectado à VPN (se necessário)
2. Teste a conexão SSH: `ssh root@5.161.112.59`
3. Verifique os logs: `ssh root@5.161.112.59 "docker logs ai-os-orchestrator"`

### Erro: "Authentication failed"
1. Execute o script de registro novamente: `./scripts/register-user.ps1` ou `./scripts/register-user.sh`
2. Verifique suas credenciais no arquivo `.ai-os-credentials.json`
3. Se o problema persistir, solicite suporte

## 📚 Recursos Adicionais

- [Documentação completa](./docs/CLIENT_SETUP_GUIDE.md)
- [Guia de desenvolvimento de agentes](./docs/AGENT_DEVELOPMENT_GUIDE.md)
- [Exemplos de código](./docs/examples/)

## 💬 Suporte

- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Email**: support@allfluence.ai

---

**Versão**: 1.0.0 | **Última atualização**: 03/07/2025