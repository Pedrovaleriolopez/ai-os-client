# 🚀 AI-OS Quick Start - Configure Claude Code + AI-OS em 15 Minutos!

## 🎯 Visão Geral do Fluxo
```
Windsurf → Terminal WSL → Claude Code → MCPs Essenciais → GitHub Auth → AI-OS Client
```

## 📥 Passo 1: Instalar Windsurf e WSL (3 min)

### 1.1 Baixe e instale o Windsurf
- **Download**: [https://www.codeium.com/windsurf/download](https://www.codeium.com/windsurf/download)
- Execute o instalador (Windows/Mac/Linux)
- Marque "Add to PATH" durante instalação

### 1.2 Configure o WSL (Windows apenas)
**PowerShell como Admin:**
```powershell
wsl --install
```
- Reinicie quando solicitado
- Após reiniciar, defina usuário e senha Ubuntu

## 🤖 Passo 2: Instalar Claude Code no WSL (5 min)

### 2.1 Abra o Windsurf e o Terminal WSL
1. Abra o Windsurf
2. Abra o terminal integrado: `Ctrl+` ` (backtick)
3. Clique no dropdown `+` → Selecione "WSL" ou "Ubuntu"
4. Você verá algo como: `user@machine:/mnt/c/Users/...`

### 2.2 Instale o Claude Code no WSL
No terminal WSL, execute:

```bash
# Instalar Node.js 20+ (necessário para Claude Code)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar Claude Code globalmente
sudo npm install -g @anthropic-ai/claude-code

# Verificar instalação
claude --version
```

### 2.3 Configure sua API Key
```bash
# Criar arquivo de configuração
mkdir -p ~/.config/claude
nano ~/.config/claude/config.json
```

Cole esta configuração:
```json
{
  "apiKey": "SUA_ANTHROPIC_API_KEY_AQUI"
}
```

Salve com `Ctrl+X`, depois `Y`, depois `Enter`.

### 2.4 Teste o Claude Code
```bash
# Teste rápido
claude "Olá, você está funcionando?"

# Deve responder algo como: "Sim, estou funcionando!"
```

## 🔧 Passo 3: Configurar MCPs Essenciais (5 min)

### 3.1 Crie o arquivo de configuração MCP
```bash
# Use o Claude Code para criar a configuração
claude "Por favor, faça o seguinte:
1. Crie o diretório: mkdir -p ~/.config/claude-desktop
2. Crie o arquivo: nano ~/.config/claude-desktop/.mcp.json
3. Aguarde eu fornecer o conteúdo"
```

### 3.2 Configure os MCPs essenciais
Cole esta configuração no arquivo `.mcp.json`:

```json
{
  "mcpServers": {
    "desktop-commander": {
      "command": "npx",
      "args": [
        "-y",
        "@wonderwhy-er/desktop-commander"
      ]
    },
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "SEU_GITHUB_TOKEN_AQUI"
      }
    }
  }
}
```

**Importante**: Você precisa de um GitHub Personal Access Token:
1. Acesse: https://github.com/settings/tokens/new
2. Nome: "AI-OS MCP Access"
3. Expiração: 90 dias (ou mais)
4. Permissões necessárias:
   - ✅ repo (acesso completo a repositórios privados)
   - ✅ workflow
   - ✅ write:packages
   - ✅ read:org
5. Clique em "Generate token"
6. Copie o token e substitua `SEU_GITHUB_TOKEN_AQUI` no arquivo

Salve com `Ctrl+X`, `Y`, `Enter`.

### 3.3 Reinicie o Claude Code para carregar os MCPs
```bash
# Feche o Claude Code se estiver em modo interativo (Ctrl+C)
# Teste se os MCPs foram carregados
claude "Liste os MCPs disponíveis usando o comando apropriado"
```

### 3.4 Configure o Windsurf/Cascade (se usar)
Para o Windsurf Cascade, adicione os mesmos MCPs:
1. No Windsurf: `Ctrl+Shift+P` → "Preferences: Open User Settings (JSON)"
2. Adicione a seção `mcpServers` com a mesma configuração acima

## 🔐 Passo 4: Clone o Repositório Privado com MCP GitHub (2 min)

### 4.1 Use o MCP GitHub para clonar
```bash
# Navegue para sua pasta de projetos
cd /mnt/c/Users/$USER/Documents
mkdir -p projetos && cd projetos

# Use o Claude Code com MCP GitHub
claude "Use o MCP GitHub para:
1. Verificar meu acesso aos repositórios com list_repositories
2. Clonar o repositório allfluencee/ai-os-client
3. Use o desktop-commander para navegar até a pasta clonada"
```

O Claude Code com MCPs irá:
- ✅ Usar o MCP GitHub para autenticação automática
- ✅ Clonar o repositório privado sem pedir senha
- ✅ Usar desktop-commander para operações de arquivo

## 🚀 Passo 5: Configurar AI-OS Client (2 min)

### 5.1 Entre no diretório e configure
```bash
cd ai-os-client

# Use o Claude Code com desktop-commander
claude "Use o desktop-commander MCP para:
1. Listar os arquivos em scripts/
2. Tornar executáveis: chmod +x scripts/*.sh
3. Execute ./scripts/register-user.sh
4. Execute ./scripts/setup-client.sh
5. Teste com: node test-mcps.js"
```

## 🎉 Pronto! Agora você tem:
- ✨ **Claude Code** rodando no terminal WSL
- 🛠️ **MCPs Essenciais** configurados (desktop-commander + github)
- 🔐 **Acesso automatizado** a repositórios privados
- 🔌 **AI-OS Client** configurado e conectado
- 🚀 **Windsurf** como seu IDE principal

## 💡 Vantagens dos MCPs Configurados

### Desktop Commander MCP
```bash
# Operações de arquivo avançadas
claude "Use desktop-commander para criar a estrutura de pastas do meu projeto"

# Edição de múltiplos arquivos
claude "Use desktop-commander para atualizar todos os arquivos .env"
```

### GitHub MCP
```bash
# Gerenciar repositórios
claude "Use o GitHub MCP para listar meus repositórios"

# Criar issues
claude "Use o GitHub MCP para criar uma issue sobre bug X"

# Gerenciar PRs
claude "Use o GitHub MCP para listar PRs abertos"
```

## 🆘 Resolução de Problemas

### "MCP não carregado"
```bash
# Verifique o arquivo de configuração
cat ~/.config/claude-desktop/.mcp.json

# Reinicie o Claude Code
# Feche com Ctrl+C e abra novamente
```

### "GitHub token inválido"
1. Gere novo token em: https://github.com/settings/tokens/new
2. Atualize no arquivo `.mcp.json`
3. Reinicie o Claude Code

### "Permission denied ao clonar"
```bash
# Verifique se o MCP GitHub está funcionando
claude "Use o GitHub MCP para executar search_repositories com query 'ai-os'"
```

### "desktop-commander não funciona"
```bash
# Teste o MCP
claude "Use o desktop-commander para executar list_directory no diretório atual"
```

## 📚 Próximos Passos

1. **Configure MCPs adicionais do AI-OS**: 
   ```bash
   cd ai-os-client
   claude "Mostre como adicionar os MCPs do arquivo docs/mcp-config-example.json"
   ```

2. **Explore capacidades dos MCPs**:
   ```bash
   claude "Liste todas as ferramentas disponíveis nos MCPs configurados"
   ```

3. **Automatize com MCPs**:
   ```bash
   claude "Crie um script usando desktop-commander e github MCPs para automatizar deploy"
   ```

## 🎓 Dicas Pro

### MCPs no Windsurf e Claude Desktop
- A mesma configuração `.mcp.json` funciona em:
  - Claude Code (terminal)
  - Claude Desktop (app)
  - Windsurf Cascade

### Organização de Tokens
```bash
# Crie um arquivo seguro para tokens
claude "Use desktop-commander para criar ~/.secrets/tokens.env com permissões 600"
```

### Debug de MCPs
```bash
# Veja logs de MCPs
claude --mcp-debug "teste conexão com GitHub MCP"
```

## 🤝 Suporte

- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Issues**: [GitHub](https://github.com/allfluencee/ai-os-client/issues)
- **Email**: support@allfluence.ai

---

**Dica Final**: Com os MCPs configurados, o Claude Code se torna uma ferramenta muito mais poderosa para automação e desenvolvimento! 🚀