# 🚀 AI-OS Quick Start - Configure Claude Code + AI-OS em 10 Minutos!

## 🎯 Visão Geral do Fluxo
```
Windsurf → Terminal WSL → Claude Code → GitHub Auth → AI-OS Client
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

## 🔐 Passo 3: Configurar GitHub para Repositório Privado (2 min)

### 3.1 Use o Claude Code para configurar o GitHub CLI
```bash
# Com o Claude Code funcionando, execute:
claude "Por favor, faça o seguinte:
1. Verifique se o GitHub CLI (gh) está instalado com 'gh --version'
2. Se não estiver, instale com: sudo apt install gh -y
3. Configure a autenticação do GitHub com: gh auth login
4. Escolha GitHub.com, HTTPS, e autentique via browser
5. Teste se funcionou com: gh auth status"
```

O Claude Code irá:
- ✅ Verificar/instalar o GitHub CLI
- ✅ Guiar você pelo processo de autenticação
- ✅ Confirmar que a autenticação funcionou

### 3.2 Clone o repositório privado AI-OS
```bash
# Navegue para sua pasta de projetos
cd /mnt/c/Users/$USER/Documents
mkdir -p projetos && cd projetos

# Agora clone com autenticação configurada
claude "Clone o repositório privado https://github.com/allfluencee/ai-os-client.git usando git clone"
```

## 🔧 Passo 4: Configurar AI-OS Client (2 min)

### 4.1 Entre no diretório e configure
```bash
cd ai-os-client

# Use o Claude Code para configurar tudo!
claude "Por favor, execute os scripts de setup do AI-OS:
1. Torne os scripts executáveis: chmod +x scripts/*.sh
2. Execute ./scripts/register-user.sh para criar minha conta
3. Execute ./scripts/setup-client.sh para configurar os MCPs
4. Teste a conexão com node test-mcps.js
Use bash para executar os comandos."
```

## 🎉 Pronto! Agora você tem:
- ✨ **Claude Code** rodando no terminal WSL
- 🔐 **GitHub CLI** configurado com acesso aos repos privados
- 🔌 **AI-OS Client** configurado e conectado
- 🚀 **Windsurf** como seu IDE principal

## 💡 Como Usar

### Desenvolvimento com Claude Code no WSL
```bash
# Sempre no terminal WSL do Windsurf
cd /mnt/c/Users/$USER/Documents/projetos/seu-projeto
claude "crie um servidor Express básico com TypeScript"
```

### Comandos Úteis do Claude Code
```bash
# Ajuda
claude --help

# Modo interativo
claude

# Executar comando direto
claude "explique o código no arquivo app.ts"

# Com contexto de arquivo
claude -f arquivo.ts "adicione tratamento de erros"
```

### Comandos GitHub CLI
```bash
# Ver status da autenticação
gh auth status

# Clonar outros repos privados
gh repo clone owner/repo

# Criar issues
gh issue create

# Criar PRs
gh pr create
```

## 🆘 Resolução de Problemas

### "Permission denied ao clonar repositório"
```bash
# Verifique a autenticação
gh auth status

# Refaça o login se necessário
gh auth logout
gh auth login
```

### "gh: command not found"
```bash
# Instale o GitHub CLI
sudo apt update
sudo apt install gh -y
```

### "claude: command not found"
```bash
# Reinstale globalmente
sudo npm install -g @anthropic-ai/claude-code

# Verifique o PATH
echo $PATH
```

### "API key não configurada"
```bash
# Verifique o arquivo de config
cat ~/.config/claude/config.json

# Ou defina via variável de ambiente
export ANTHROPIC_API_KEY="sua-key-aqui"
```

### "WSL não abre no Windsurf"
1. Verifique se WSL está instalado: `wsl --list` (PowerShell)
2. Reinicie o Windsurf
3. Tente: Terminal → New Terminal → WSL

## 📚 Próximos Passos

1. **Explore os exemplos**: 
   ```bash
   claude "mostre os exemplos em docs/examples/"
   ```

2. **Crie seu primeiro agente**:
   ```bash
   claude "crie um agente AI seguindo o guia em docs/AGENT_DEVELOPMENT_GUIDE.md"
   ```

3. **Automatize tarefas**:
   ```bash
   claude "crie um script que automatiza o deploy de agentes"
   ```

## 🎓 Dicas Pro

### Autenticação GitHub permanente
```bash
# Configure cache de credenciais
gh auth setup-git

# Isso evita ter que autenticar sempre
```

### Workspace do Claude Code
```bash
# Claude Code entende o contexto do diretório atual
cd seu-projeto
claude "analise a estrutura deste projeto"
```

### Múltiplas janelas WSL
- Abra várias abas de terminal WSL no Windsurf
- Uma para Claude Code interativo
- Outra para comandos gerais

### Trabalhar com repos privados
```bash
# Liste seus repos
gh repo list

# Clone qualquer repo privado
gh repo clone seu-usuario/seu-repo-privado
```

## 🤝 Suporte

- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Issues**: [GitHub](https://github.com/allfluencee/ai-os-client/issues)
- **Email**: support@allfluence.ai

---

**Dica Final**: Com o GitHub CLI configurado, você pode trabalhar com qualquer repositório privado diretamente do terminal WSL usando o Claude Code! 🚀