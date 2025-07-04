# 🤖 Comandos para Cascade Executar no Windsurf

## Para Windows com WSL (Recomendado)

**IMPORTANTE**: No Windsurf, use o terminal WSL em vez do PowerShell!

### Como abrir terminal WSL no Windsurf:
1. Pressione `Ctrl+` ` (backtick) para abrir o terminal
2. Clique no dropdown `+` → Selecione "WSL" ou "Ubuntu"
3. Agora você está no ambiente Linux

### Script para executar no terminal WSL:

```bash
#!/bin/bash

# 1. Navegar para o diretório do projeto Windows
cd /mnt/c/projetos/ai-os-client

# 2. Verificar se Git está instalado
if ! command -v git &> /dev/null; then
    echo "📦 Instalando Git..."
    sudo apt update
    sudo apt install git -y
fi

# 3. Clonar o repositório (se ainda não clonado)
if [ ! -d ".git" ]; then
    echo "📥 Clonando repositório AI-OS Client..."
    git clone https://github.com/allfluencee/ai-os-client.git .
fi

# 4. Dar permissão aos scripts
echo "🔓 Configurando permissões..."
chmod +x scripts/*.sh

# 5. Executar registro
echo -e "\n🔐 Iniciando processo de registro/login..."
./scripts/register-user.sh

# 6. Executar setup
echo -e "\n🚀 Configurando ambiente AI-OS..."
./scripts/setup-client.sh

# 7. Testar conexão
echo -e "\n🧪 Testando conexão com MCPs..."
echo "Execute 'node test-mcps.js' para validar a configuração"
```

## Para Mac/Linux (Bash)

```bash
#!/bin/bash

# 1. Verificar se Git está instalado
if ! command -v git &> /dev/null; then
    echo "❌ Git não está instalado."
    echo "Mac: Execute 'xcode-select --install'"
    echo "Linux: Execute 'sudo apt install git' ou 'sudo yum install git'"
    exit 1
fi

# 2. Clonar o repositório (se ainda não clonado)
if [ ! -d ".git" ]; then
    echo "📥 Clonando repositório AI-OS Client..."
    git clone https://github.com/allfluencee/ai-os-client.git .
fi

# 3. Dar permissão aos scripts
echo "🔓 Configurando permissões..."
chmod +x scripts/*.sh

# 4. Executar registro
echo -e "\n🔐 Iniciando processo de registro/login..."
./scripts/register-user.sh

# 5. Executar setup
echo -e "\n🚀 Configurando ambiente AI-OS..."
./scripts/setup-client.sh

# 6. Testar conexão
echo -e "\n🧪 Testando conexão com MCPs..."
echo "Execute 'node test-mcps.js' para validar a configuração"
```

## Comando Único para Cascade no Windsurf

### Windows (usar terminal WSL):
```
Por favor, abra um terminal WSL no Windsurf e execute:
cd /mnt/c/projetos/ai-os-client && git clone https://github.com/allfluencee/ai-os-client.git . && chmod +x scripts/*.sh && ./scripts/register-user.sh && ./scripts/setup-client.sh
```

### Mac/Linux:
```
Por favor execute este comando bash para configurar o AI-OS:
git clone https://github.com/allfluencee/ai-os-client.git . && chmod +x scripts/*.sh && ./scripts/register-user.sh && ./scripts/setup-client.sh
```

## Prompt Completo para o Cascade

Cole isso no Cascade (Ctrl+L) para configuração automática:

```
Configure o AI-OS Client neste projeto Windows:

1. Abra um terminal WSL (não PowerShell)
2. Navegue para /mnt/c/projetos/ai-os-client
3. Clone https://github.com/allfluencee/ai-os-client
4. Execute chmod +x scripts/*.sh
5. Execute ./scripts/register-user.sh
6. Execute ./scripts/setup-client.sh
7. Teste com node test-mcps.js

Use APENAS o terminal WSL para todos os comandos.
```