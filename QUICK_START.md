# 🚀 AI-OS Quick Start - Configure Claude Desktop + MCPs + AI-OS em 20 Minutos!

## 🎯 Visão Geral do Fluxo
```
Windsurf → Terminal WSL → Claude Desktop → Instalar MCPs → Configurar MCPs → GitHub → AI-OS Client
```

## 📥 Passo 1: Instalar Windsurf, Claude Desktop e WSL (5 min)

### 1.1 Baixe e instale o Windsurf
- **Download**: [https://www.codeium.com/windsurf/download](https://www.codeium.com/windsurf/download)
- Execute o instalador (Windows/Mac/Linux)
- Marque "Add to PATH" durante instalação

### 1.2 Baixe e instale o Claude Desktop
- **Download**: [https://claude.ai/download](https://claude.ai/download)
- Instale o aplicativo Claude Desktop
- Faça login com sua conta Anthropic

### 1.3 Configure o WSL (Windows apenas)
**PowerShell como Admin:**
```powershell
wsl --install
```
- Reinicie quando solicitado
- Após reiniciar, defina usuário e senha Ubuntu

## 🛠️ Passo 2: Instalar MCPs Globalmente no WSL (10 min)

### 2.1 Abra o Windsurf e o Terminal WSL
1. Abra o Windsurf
2. Abra o terminal integrado: `Ctrl+` ` (backtick)
3. Clique no dropdown `+` → Selecione "WSL" ou "Ubuntu"
4. Você verá algo como: `user@machine:/mnt/c/Users/...`

### 2.2 Instale Node.js e ferramentas essenciais
```bash
# Instalar Node.js 20+
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar Python e pip (necessário para alguns MCPs)
sudo apt update
sudo apt install -y python3 python3-pip

# Instalar pipx para MCPs Python
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# Recarregar PATH
source ~/.bashrc
```

### 2.3 Instale TODOS os MCPs necessários globalmente
```bash
# MCPs essenciais - Instalar primeiro para evitar problemas
npm install -g @modelcontextprotocol/server-github
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @wonderwhy-er/desktop-commander

# MCPs do AI-OS
npm install -g @modelcontextprotocol/server-git
npm install -g @modelcontextprotocol/server-puppeteer
npm install -g @supabase/mcp-server-supabase@latest
npm install -g @upstash/context7-mcp
npm install -g @21st-dev/magic@latest
npm install -g exa-mcp-server
npm install -g ssh-mcp
npm install -g @taazkareem/clickup-mcp-server@latest

# MCP Git via Python (se preferir)
pipx install mcp-server-git

# Verificar instalações
npm list -g --depth=0 | grep mcp
npm list -g --depth=0 | grep modelcontextprotocol
```

### 2.4 Obtenha as credenciais necessárias

Você precisará das seguintes credenciais (peça ao administrador ou crie suas próprias):

1. **GitHub Personal Access Token**:
   - Acesse: https://github.com/settings/tokens/new
   - Permissões: repo, workflow, write:packages, read:org
   
2. **Supabase Access Token**:
   - Acesse: https://supabase.com/dashboard/account/tokens
   
3. **EXA API Key**:
   - Acesse: https://exa.ai/dashboard
   
4. **Context7 (opcional)**:
   - Geralmente não precisa de configuração
   
5. **21st.dev API Key**:
   - Acesse: https://21st.dev/api-keys

## 🔧 Passo 3: Configurar Claude Desktop com MCPs (5 min)

### 3.1 Localize o arquivo de configuração do Claude Desktop

**Windows (WSL)**:
```bash
# O arquivo está no Windows, acesse via WSL
nano "/mnt/c/Users/$USER/AppData/Roaming/Claude/claude_desktop_config.json"
```

**Mac**:
```bash
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**Linux**:
```bash
nano ~/.config/Claude/claude_desktop_config.json
```

### 3.2 Configure todos os MCPs no claude_desktop_config.json

Substitua TODO o conteúdo do arquivo por:

```json
{
  "mcpServers": {
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@wonderwhy-er/desktop-commander"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "SEU_GITHUB_TOKEN_AQUI"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"],
      "env": {
        "ALLOWED_PATHS": "/mnt/c/Users/$USER/Documents,/home/$USER"
      }
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "/mnt/c/Users/$USER/Documents/projetos"]
    },
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--access-token",
        "SEU_SUPABASE_TOKEN_AQUI"
      ]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "21st-dev-magic": {
      "command": "npx",
      "args": ["-y", "@21st-dev/magic@latest"],
      "env": {
        "API_KEY": "SEU_21ST_API_KEY_AQUI"
      }
    },
    "exa": {
      "command": "npx",
      "args": [
        "-y",
        "exa-mcp-server",
        "--tools=web_search_exa,research_paper_search,company_research,crawling,competitor_finder,linkedin_search,wikipedia_search_exa,github_search"
      ],
      "env": {
        "EXA_API_KEY": "SEU_EXA_API_KEY_AQUI"
      }
    },
    "ssh-main": {
      "command": "npx",
      "args": [
        "ssh-mcp",
        "-y",
        "--",
        "--host=SEU_HOST_SSH",
        "--port=22",
        "--user=SEU_USER",
        "--password=SUA_SENHA"
      ]
    }
  }
}
```

**IMPORTANTE**: Substitua todos os valores `SEU_*_AQUI` pelas suas credenciais reais.

### 3.3 Reinicie o Claude Desktop
1. Feche completamente o Claude Desktop
2. Abra novamente
3. Os MCPs devem aparecer no menu de ferramentas

## 🔐 Passo 4: Clone o Repositório Privado (2 min)

### 4.1 Use o Claude Desktop para clonar
No Claude Desktop, digite:

```
Use o MCP GitHub para:
1. Verificar minha autenticação com get_authenticated_user
2. Listar meus repositórios com search_repositories query:"ai-os-client"
3. Clonar o repositório allfluencee/ai-os-client para /mnt/c/Users/$USER/Documents/projetos
4. Use o desktop-commander para confirmar que foi clonado
```

### 4.2 Entre no diretório do projeto
```bash
# No terminal WSL do Windsurf
cd /mnt/c/Users/$USER/Documents/projetos/ai-os-client
```

## 🚀 Passo 5: Configurar AI-OS Client (3 min)

### 5.1 Use o Claude Desktop para configurar
No Claude Desktop:

```
Por favor, use o desktop-commander para:
1. Navegar até /mnt/c/Users/$USER/Documents/projetos/ai-os-client
2. Listar os arquivos em scripts/
3. Executar: chmod +x scripts/*.sh
4. Executar: ./scripts/register-user.sh
5. Executar: ./scripts/setup-client.sh
6. Testar com: node test-mcps.js
```

## 🎉 Pronto! Agora você tem:
- ✨ **Claude Desktop** com todos os MCPs configurados
- 🛠️ **MCPs Globalmente Instalados** para evitar problemas
- 🔐 **Acesso completo** a repositórios privados e serviços
- 🔌 **AI-OS Client** configurado e conectado
- 🚀 **Windsurf** como seu IDE principal

## 💡 Testando os MCPs

### No Claude Desktop, teste cada MCP:
```
# Desktop Commander
Use o desktop-commander para listar arquivos em /mnt/c/Users

# GitHub
Use o GitHub MCP para listar meus repositórios

# Supabase
Use o Supabase MCP para listar projetos

# Context7
Use o Context7 MCP para pesquisar documentação sobre React

# EXA
Use o EXA MCP para pesquisar sobre "AI agents development"

# SSH (se configurado)
Use o SSH MCP para executar "ls -la" no servidor
```

## 🆘 Resolução de Problemas

### "MCP não aparece no Claude Desktop"
1. Verifique se instalou globalmente: `npm list -g | grep mcp`
2. Verifique o arquivo: `cat /mnt/c/Users/$USER/AppData/Roaming/Claude/claude_desktop_config.json`
3. Reinicie o Claude Desktop completamente

### "Erro de autenticação no GitHub"
```bash
# Teste o token
curl -H "Authorization: token SEU_TOKEN" https://api.github.com/user
```

### "npx -y falhou na instalação"
```bash
# Instale manualmente sem o -y
npm install -g @modelcontextprotocol/server-github
```

### "Permission denied nos scripts"
```bash
# No WSL
chmod +x scripts/*.sh
# Ou use sudo se necessário
sudo chmod +x scripts/*.sh
```

## 📚 Configuração Adicional dos MCPs AI-OS

Após o setup inicial, você receberá um arquivo com MCPs específicos do AI-OS incluindo:
- Portainer MCP para gerenciar containers
- Task Master AI para gerenciamento de tarefas
- MCPs customizados para seus serviços

## 🎓 Dicas Pro

### Organização de Credenciais
```bash
# Crie um arquivo seguro para suas credenciais
mkdir -p ~/.secrets
nano ~/.secrets/mcp-credentials.txt
chmod 600 ~/.secrets/mcp-credentials.txt
```

### Backup da Configuração
```bash
# Faça backup do claude_desktop_config.json
cp /mnt/c/Users/$USER/AppData/Roaming/Claude/claude_desktop_config.json ~/backup-claude-config.json
```

### Atualizações dos MCPs
```bash
# Atualize todos os MCPs globais
npm update -g
```

## 🤝 Suporte

- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Issues**: [GitHub](https://github.com/allfluencee/ai-os-client/issues)
- **Email**: support@allfluence.ai

---

**Nota Importante**: Este guia assume que você tem acesso aos serviços AI-OS. Se não tiver as credenciais necessárias, entre em contato com o administrador do sistema.