# 🚀 AI-OS Quick Start - Configure em 5 Minutos!

## 📥 Passo 1: Instalar as Ferramentas (3 min)

### 1.1 Baixe e instale o Windsurf
- **Download**: [https://www.codeium.com/windsurf/download](https://www.codeium.com/windsurf/download)
- Escolha sua versão: Windows, Mac ou Linux
- Execute o instalador e siga as instruções
- Durante a instalação, marque a opção "Add to PATH"

### 1.2 Configure o WSL (Windows apenas)
Se você usa Windows, precisa do WSL para o Claude Code funcionar:

**PowerShell como Admin:**
```powershell
wsl --install
```
- Reinicie o computador quando solicitado
- Após reiniciar, defina usuário e senha para o Ubuntu

## ⚙️ Passo 2: Configurar Windsurf + Cascade (2 min)

### 2.1 Abra o Windsurf

### 2.2 Configure o Cascade (AI integrado do Windsurf)
1. Pressione `Ctrl+Shift+P` (Windows) ou `Cmd+Shift+P` (Mac)
2. Digite: `Windsurf: Sign in`
3. Faça login com sua conta do Windsurf/Codeium

### 2.3 Ative o Cascade
1. Clique no ícone do Cascade na barra lateral direita
2. Ou pressione `Ctrl+L` (Windows) ou `Cmd+L` (Mac)
3. O Cascade é o assistente AI do Windsurf (similar ao Claude Code)

## 🎯 Passo 3: Setup Automático com Cascade

### 3.1 Crie uma nova pasta para o projeto
```bash
# Windows (PowerShell)
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

### 3.3 Use o Cascade para configurar tudo!

No Cascade (Ctrl+L ou Cmd+L), cole este comando:

```
Por favor, configure o AI-OS Client para mim no Windows com WSL:

1. Abra um terminal WSL integrado no Windsurf
2. Clone o repositório: https://github.com/allfluencee/ai-os-client
3. Execute o script de registro para criar minha conta
4. Execute o script de setup para configurar os MCPs
5. Configure o Git se necessário
6. Teste a conexão com os MCPs

Use o terminal WSL para todos os comandos. O repositório está no diretório atual.
```

## 🎉 Pronto!

O Cascade irá:
- ✅ Abrir terminal WSL no Windsurf
- ✅ Clonar o repositório
- ✅ Executar o registro/login
- ✅ Configurar todos os MCPs automaticamente
- ✅ Criar todos os arquivos de configuração
- ✅ Testar as conexões

## 💡 Dicas Importantes para Windows

### Terminal WSL no Windsurf
1. Abra o terminal integrado: `Ctrl+` ` (backtick)
2. Clique no dropdown ao lado do `+` no terminal
3. Selecione "WSL" ou "Ubuntu"
4. Agora você está no ambiente Linux!

### Comandos Rápidos no WSL
```bash
# Navegar para o projeto (a partir do WSL)
cd /mnt/c/projetos/ai-os-client

# Clonar e configurar tudo
git clone https://github.com/allfluencee/ai-os-client.git .
chmod +x scripts/*.sh
./scripts/register-user.sh
./scripts/setup-client.sh
```

### Integração Windows ↔ WSL
- Seus arquivos Windows estão em: `/mnt/c/`
- Exemplo: `C:\projetos` → `/mnt/c/projetos`
- O Windsurf vê ambos os sistemas de arquivos!

## 🆘 Problemas Comuns

### "WSL não está instalado"
Execute no PowerShell como Admin:
```powershell
wsl --install
# Reinicie o computador após a instalação
```

### "Git não encontrado no WSL"
No terminal WSL:
```bash
sudo apt update
sudo apt install git -y
```

### "Permissão negada ao executar scripts"
No terminal WSL:
```bash
chmod +x scripts/*.sh
```

### "SSH key não configurada"
O Cascade pode ajudar! No Cascade, digite:
```
Por favor, gere uma chave SSH no WSL e mostre como adicionar ao servidor AI-OS
```

### "Terminal WSL não aparece no Windsurf"
1. Certifique-se que o WSL está instalado e funcionando
2. Teste no PowerShell: `wsl --list`
3. Reinicie o Windsurf
4. O terminal WSL deve aparecer nas opções de terminal

## 📚 Próximos Passos

Após o setup, você pode:
- Desenvolver agentes AI (veja `docs/AGENT_DEVELOPMENT_GUIDE.md`)
- Testar os MCPs com `node test-mcps.js`
- Explorar exemplos em `docs/examples/`

## 🎓 Aprenda Mais

- **Tutorial em Vídeo**: [Em breve]
- **Discord**: [AI-OS Community](https://discord.gg/ai-os)
- **Documentação Completa**: `docs/CLIENT_SETUP_GUIDE.md`

## 🤖 Sobre Windsurf e Cascade

**Windsurf** é um IDE baseado no VS Code com AI integrada, desenvolvido pela Codeium.

**Cascade** é o assistente AI do Windsurf que:
- Entende seu código completo
- Pode editar múltiplos arquivos
- Executa comandos no terminal
- Similar ao Claude Code, mas integrado no IDE

**Diferença principal**: Cascade roda dentro do Windsurf, enquanto o Claude Code original roda no terminal.

---

**Dúvidas?** No Cascade, apenas pergunte: "Como faço para...?"