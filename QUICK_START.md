# 🚀 AI-OS Quick Start - Configure em 5 Minutos!

## 📥 Passo 1: Instalar as Ferramentas (3 min)

### 1.1 Baixe e instale o Windsurf
- **Download**: [https://www.codeium.com/windsurf/download](https://www.codeium.com/windsurf/download)
- Escolha sua versão: Windows, Mac ou Linux
- Execute o instalador e siga as instruções

### 1.2 Baixe e instale o Claude Desktop
- **Download**: [https://claude.ai/download](https://claude.ai/download)
- Disponível para Windows e Mac
- Execute o instalador

## ⚙️ Passo 2: Configurar Claude Code no Windsurf (2 min)

### 2.1 Abra o Windsurf

### 2.2 Configure o Claude Code
1. Pressione `Ctrl+Shift+P` (Windows) ou `Cmd+Shift+P` (Mac)
2. Digite: `Claude: Sign in`
3. Faça login com sua conta Anthropic

### 2.3 Ative o Claude Code
1. Clique no ícone do Claude na barra lateral esquerda
2. Ou pressione `Ctrl+L` (Windows) ou `Cmd+L` (Mac)

## 🎯 Passo 3: Setup Automático com Claude Code

### 3.1 Crie uma nova pasta para o projeto
```bash
# Windows
mkdir C:\projetos\ai-os-client
cd C:\projetos\ai-os-client

# Mac/Linux
mkdir ~/projetos/ai-os-client
cd ~/projetos/ai-os-client
```

### 3.2 Abra no Windsurf
```bash
windsurf .
```

### 3.3 Use o Claude Code para configurar tudo!

No Claude Code (Ctrl+L ou Cmd+L), cole este comando:

```
Por favor, configure o AI-OS Client para mim:

1. Clone o repositório: https://github.com/allfluencee/ai-os-client
2. Execute o script de registro para criar minha conta
3. Execute o script de setup para configurar os MCPs
4. Configure o Git se necessário
5. Teste a conexão com os MCPs

Use os scripts PowerShell no Windows ou bash no Mac/Linux conforme apropriado.
```

## 🎉 Pronto!

O Claude Code irá:
- ✅ Clonar o repositório
- ✅ Executar o registro/login
- ✅ Configurar todos os MCPs automaticamente
- ✅ Criar todos os arquivos de configuração
- ✅ Testar as conexões

## 💡 Dicas

### Comando Rápido para Windows
Se preferir, cole este comando único no Claude Code:
```
Execute no PowerShell: 
git clone https://github.com/allfluencee/ai-os-client.git . && ./scripts/register-user.ps1 && ./scripts/setup-client.ps1
```

### Comando Rápido para Mac/Linux
```
Execute no terminal:
git clone https://github.com/allfluencee/ai-os-client.git . && chmod +x scripts/*.sh && ./scripts/register-user.sh && ./scripts/setup-client.sh
```

## 🆘 Problemas Comuns

### "Git não encontrado"
- **Windows**: [Baixar Git](https://git-scm.com/download/win)
- **Mac**: Instale via terminal: `xcode-select --install`
- **Linux**: `sudo apt install git` ou `sudo yum install git`

### "PowerShell não permite executar scripts"
No PowerShell como Admin:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "SSH key não configurada"
O Claude Code pode gerar uma para você! Peça:
```
Por favor, gere uma chave SSH para mim e mostre como adicionar ao servidor AI-OS
```

## 📚 Próximos Passos

Após o setup, você pode:
- Desenvolver agentes AI (veja `docs/AGENT_DEVELOPMENT_GUIDE.md`)
- Testar os MCPs com `node test-mcps.js`
- Explorar exemplos em `docs/examples/`

## 🎓 Aprenda Mais

- **Tutorial em Vídeo**: [Em breve]
- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Documentação Completa**: `docs/CLIENT_SETUP_GUIDE.md`

---

**Dúvidas?** No Claude Code, apenas pergunte: "Como faço para...?"