#!/bin/bash

# 🚀 AI-OS Client Setup Script
# Automatiza a configuração do ambiente cliente

set -e

echo "🚀 AI-OS Client Setup"
echo "====================="
echo ""

# Detectar OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

echo "📋 Sistema detectado: $OS"

# Função para ler input
read_input() {
    local prompt="$1"
    local default="$2"
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        if [ -z "$input" ]; then
            input="$default"
        fi
    else
        read -p "$prompt: " input
    fi
    
    echo "$input"
}

# Verificar credenciais salvas
credentialsFile=".ai-os-credentials.json"
if [ -f "$credentialsFile" ]; then
    echo "📋 Credenciais encontradas em $credentialsFile"
    
    # Parse JSON file
    USER_EMAIL=$(grep -o '"USER_EMAIL":[[:space:]]*"[^"]*"' "$credentialsFile" | sed 's/.*"USER_EMAIL":[[:space:]]*"\([^"]*\)".*/\1/')
    USER_ID=$(grep -o '"USER_ID":[[:space:]]*"[^"]*"' "$credentialsFile" | sed 's/.*"USER_ID":[[:space:]]*"\([^"]*\)".*/\1/')
    TENANT_ID=$(grep -o '"TENANT_ID":[[:space:]]*"[^"]*"' "$credentialsFile" | sed 's/.*"TENANT_ID":[[:space:]]*"\([^"]*\)".*/\1/')
    API_TOKEN=$(grep -o '"API_TOKEN":[[:space:]]*"[^"]*"' "$credentialsFile" | sed 's/.*"API_TOKEN":[[:space:]]*"\([^"]*\)".*/\1/')
    
    echo "USER_EMAIL: $USER_EMAIL"
    echo "USER_ID: $USER_ID"
    echo "TENANT_ID: $TENANT_ID"
    echo ""
    
    use_credentials=$(read_input "Usar essas credenciais? (s/n)" "s")
    if [ "$use_credentials" != "s" ]; then
        # Coletar novas informações
        echo "📝 Informações do usuário:"
        USER_EMAIL=$(read_input "Seu email")
        USER_ID=$(read_input "Seu ID de usuário" "${USER_EMAIL%%@*}")
        TENANT_ID=$(read_input "Tenant ID" "default")
    fi
else
    echo "⚠️ Nenhuma credencial salva encontrada."
    echo "💡 Execute ./register-user.sh para se registrar primeiro."
    echo ""
    
    # Coletar informações do usuário
    echo "📝 Informações do usuário:"
    USER_EMAIL=$(read_input "Seu email")
    USER_ID=$(read_input "Seu ID de usuário" "${USER_EMAIL%%@*}")
    TENANT_ID=$(read_input "Tenant ID" "default")
fi

SERVER_IP=$(read_input "Servidor AI-OS" "5.161.112.59")

# Verificar SSH
echo ""
echo "🔐 Verificando SSH..."
if ! ssh -o BatchMode=yes -o ConnectTimeout=5 root@$SERVER_IP exit 2>/dev/null; then
    echo "❌ SSH não configurado. Configurando agora..."
    
    # Gerar chave SSH se não existir
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "🔑 Gerando chave SSH..."
        ssh-keygen -t rsa -b 4096 -C "$USER_EMAIL" -f ~/.ssh/id_rsa -N ""
    fi
    
    echo ""
    echo "📋 Copie esta chave pública para o servidor:"
    echo "----------------------------------------"
    cat ~/.ssh/id_rsa.pub
    echo "----------------------------------------"
    echo ""
    echo "Execute no servidor: echo 'CHAVE_ACIMA' >> ~/.ssh/authorized_keys"
    echo ""
    read -p "Pressione ENTER quando a chave estiver configurada..."
fi

# Testar conexão SSH
if ssh -o BatchMode=yes -o ConnectTimeout=5 root@$SERVER_IP exit; then
    echo "✅ SSH configurado com sucesso!"
else
    echo "❌ Erro na configuração SSH. Verifique e tente novamente."
    exit 1
fi

# Criar estrutura de diretórios
echo ""
echo "📁 Criando estrutura de diretórios..."
mkdir -p .claude
mkdir -p .vscode

# Criar .mcp.json
echo "🤖 Criando configuração MCP..."
cat > .mcp.json << EOF
{
  "mcpServers": {
    "ai-os-orchestrator": {
      "command": "ssh",
      "args": [
        "root@$SERVER_IP",
        "docker exec -i ai-os-orchestrator node /app/dist/mcp-server.js"
      ],
      "env": {
        "USER_ID": "$USER_ID",
        "USER_EMAIL": "$USER_EMAIL",
        "TENANT_ID": "$TENANT_ID"
      }
    },
    "global-memory-hub": {
      "command": "ssh",
      "args": [
        "root@$SERVER_IP",
        "docker exec -i global-memory-hub node /app/dist/mcp-server.js"
      ],
      "env": {
        "USER_ID": "$USER_ID",
        "USER_EMAIL": "$USER_EMAIL",
        "TENANT_ID": "$TENANT_ID"
      }
    },
    "context-manager": {
      "command": "ssh",
      "args": [
        "root@$SERVER_IP",
        "docker exec -i context-manager node /app/dist/mcp-server.js"
      ],
      "env": {
        "USER_ID": "$USER_ID",
        "USER_EMAIL": "$USER_EMAIL",
        "TENANT_ID": "$TENANT_ID"
      }
    },
    "document-graph": {
      "command": "ssh",
      "args": [
        "root@$SERVER_IP",
        "docker exec -i document-graph-mcp node /app/dist/index.js"
      ],
      "env": {
        "USER_ID": "$USER_ID",
        "USER_EMAIL": "$USER_EMAIL",
        "TENANT_ID": "$TENANT_ID"
      }
    }
  }
}
EOF

# Criar .env.local
echo "🔧 Criando variáveis de ambiente..."
cat > .env.local << EOF
# Identificação do usuário
USER_ID=$USER_ID
USER_EMAIL=$USER_EMAIL
TENANT_ID=$TENANT_ID

# Supabase (projeto principal)
NEXT_PUBLIC_SUPABASE_URL=https://goqtkwyiokmdixpahvoc.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdvcXRrd3lpb2ttZGl4cGFodm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NzM2MTcsImV4cCI6MjA2NjU0OTYxN30.4pgM8zQBA_J85yXHpn7Tu4WiAE6tylK5Kek8eB0rZFc

# API Gateway
API_GATEWAY_URL=https://api.allfluence.ai

# MCP Endpoints
ORCHESTRATOR_URL=https://orchestrator.allfluence.ai
MEMORY_HUB_URL=https://memory.allfluence.ai
EOF

# Criar .claude/settings.json
echo "⚙️ Configurando Claude Code..."
cat > .claude/settings.json << EOF
{
  "env": {
    "USER_ID": "$USER_ID",
    "USER_EMAIL": "$USER_EMAIL",
    "TENANT_ID": "$TENANT_ID"
  },
  "allowedTools": [
    "Edit",
    "Read",
    "Write",
    "Bash",
    "mcp__*"
  ]
}
EOF

# Testar conexão com MCPs
echo ""
echo "🧪 Testando conexão com MCPs..."

# Testar Orchestrator
echo -n "Testando Orchestrator... "
if ssh root@$SERVER_IP "docker exec ai-os-orchestrator echo 'OK'" >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

# Testar Memory Hub
echo -n "Testando Memory Hub... "
if ssh root@$SERVER_IP "docker exec global-memory-hub echo 'OK'" >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

# Testar Context Manager
echo -n "Testando Context Manager... "
if ssh root@$SERVER_IP "docker exec context-manager echo 'OK'" >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

# Testar Document Graph
echo -n "Testando Document Graph... "
if ssh root@$SERVER_IP "docker exec document-graph-mcp echo 'OK'" >/dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

# Criar script de teste
echo ""
echo "📝 Criando script de teste..."
cat > test-mcps.js << 'EOF'
// Test script para validar MCPs
console.log("🧪 Testando MCPs do AI-OS...\n");

// Este script deve ser executado dentro do Claude Code
// após abrir o projeto com as configurações MCP

async function testMCPs() {
    console.log("1. Testando Orchestrator...");
    try {
        const workflows = await orchestrator.listWorkflows();
        console.log("✅ Orchestrator: " + workflows.length + " workflows disponíveis");
    } catch (e) {
        console.log("❌ Orchestrator: " + e.message);
    }

    console.log("\n2. Testando Memory Hub...");
    try {
        const testKey = "test-" + Date.now();
        await memory.store(testKey, { test: true, user: process.env.USER_ID });
        const data = await memory.retrieve(testKey);
        console.log("✅ Memory Hub: Funcionando");
        await memory.delete(testKey);
    } catch (e) {
        console.log("❌ Memory Hub: " + e.message);
    }

    console.log("\n3. Testando Context Manager...");
    try {
        const structure = await context.getProjectStructure();
        console.log("✅ Context Manager: Funcionando");
    } catch (e) {
        console.log("❌ Context Manager: " + e.message);
    }

    console.log("\n4. Testando Document Graph...");
    try {
        const result = await graph.query("MATCH (n) RETURN count(n) as count LIMIT 1");
        console.log("✅ Document Graph: Funcionando");
    } catch (e) {
        console.log("❌ Document Graph: " + e.message);
    }
}

// Executar testes
testMCPs().then(() => {
    console.log("\n✅ Teste concluído!");
}).catch(console.error);
EOF

# Instruções finais
echo ""
echo "✅ Setup concluído!"
echo ""
echo "📋 Próximos passos:"
echo "1. Abra este diretório no Claude Code ou Windsurf"
echo "2. Os MCPs serão carregados automaticamente"
echo "3. Execute o arquivo test-mcps.js para validar a conexão"
echo ""
echo "🔧 Arquivos criados:"
echo "- .mcp.json (configuração dos MCPs)"
echo "- .env.local (variáveis de ambiente)"
echo "- .claude/settings.json (configuração do Claude Code)"
echo "- test-mcps.js (script de teste)"
echo ""
echo "📚 Documentação completa em: docs/CLIENT_SETUP_GUIDE.md"
echo ""