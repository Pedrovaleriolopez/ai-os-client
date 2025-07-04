# 🚀 AI-OS Client Setup Script (PowerShell)
# Automatiza a configuração do ambiente cliente no Windows

Write-Host "🚀 AI-OS Client Setup" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

# Função para ler input
function Read-Input {
    param(
        [string]$Prompt,
        [string]$Default
    )
    
    if ($Default) {
        $input = Read-Host "$Prompt [$Default]"
        if ([string]::IsNullOrWhiteSpace($input)) {
            return $Default
        }
        return $input
    } else {
        return Read-Host $Prompt
    }
}

# Verificar credenciais salvas
$credentialsFile = ".ai-os-credentials.json"
if (Test-Path $credentialsFile) {
    Write-Host "📋 Credenciais encontradas em $credentialsFile" -ForegroundColor Green
    $credentials = Get-Content $credentialsFile | ConvertFrom-Json
    
    $USER_EMAIL = $credentials.USER_EMAIL
    $USER_ID = $credentials.USER_ID
    $TENANT_ID = $credentials.TENANT_ID
    $API_TOKEN = $credentials.API_TOKEN
    
    Write-Host "USER_EMAIL: $USER_EMAIL" -ForegroundColor Cyan
    Write-Host "USER_ID: $USER_ID" -ForegroundColor Cyan
    Write-Host "TENANT_ID: $TENANT_ID" -ForegroundColor Cyan
    Write-Host ""
    
    $useCredentials = Read-Input -Prompt "Usar essas credenciais? (s/n)" -Default "s"
    if ($useCredentials -ne "s") {
        # Coletar novas informações
        Write-Host "📝 Informações do usuário:" -ForegroundColor Yellow
        $USER_EMAIL = Read-Input -Prompt "Seu email"
        $USER_ID = Read-Input -Prompt "Seu ID de usuário" -Default ($USER_EMAIL -split '@')[0]
        $TENANT_ID = Read-Input -Prompt "Tenant ID" -Default "default"
    }
} else {
    Write-Host "⚠️ Nenhuma credencial salva encontrada." -ForegroundColor Yellow
    Write-Host "💡 Execute ./register-user.ps1 para se registrar primeiro." -ForegroundColor Cyan
    Write-Host ""
    
    # Coletar informações do usuário
    Write-Host "📝 Informações do usuário:" -ForegroundColor Yellow
    $USER_EMAIL = Read-Input -Prompt "Seu email"
    $USER_ID = Read-Input -Prompt "Seu ID de usuário" -Default ($USER_EMAIL -split '@')[0]
    $TENANT_ID = Read-Input -Prompt "Tenant ID" -Default "default"
}

$SERVER_IP = Read-Input -Prompt "Servidor AI-OS" -Default "5.161.112.59"

# Verificar SSH
Write-Host ""
Write-Host "🔐 Verificando SSH..." -ForegroundColor Yellow

$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"
$sshConfigPath = "$env:USERPROFILE\.ssh\config"

# Criar diretório .ssh se não existir
if (!(Test-Path "$env:USERPROFILE\.ssh")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force | Out-Null
}

# Gerar chave SSH se não existir
if (!(Test-Path $sshKeyPath)) {
    Write-Host "🔑 Gerando chave SSH..." -ForegroundColor Yellow
    ssh-keygen -t rsa -b 4096 -C $USER_EMAIL -f $sshKeyPath -N '""'
}

# Testar conexão SSH
$sshTest = ssh -o BatchMode=yes -o ConnectTimeout=5 root@$SERVER_IP exit 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ SSH não configurado. Configure manualmente:" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Copie esta chave pública para o servidor:" -ForegroundColor Yellow
    Write-Host "----------------------------------------"
    Get-Content "$sshKeyPath.pub"
    Write-Host "----------------------------------------"
    Write-Host ""
    Write-Host "Execute no servidor: echo 'CHAVE_ACIMA' >> ~/.ssh/authorized_keys"
    Write-Host ""
    Read-Host "Pressione ENTER quando a chave estiver configurada"
    
    # Testar novamente
    $sshTest = ssh -o BatchMode=yes -o ConnectTimeout=5 root@$SERVER_IP exit 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erro na configuração SSH. Verifique e tente novamente." -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ SSH configurado com sucesso!" -ForegroundColor Green

# Criar estrutura de diretórios
Write-Host ""
Write-Host "📁 Criando estrutura de diretórios..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path ".claude" -Force | Out-Null
New-Item -ItemType Directory -Path ".vscode" -Force | Out-Null

# Criar .mcp.json
Write-Host "🤖 Criando configuração MCP..." -ForegroundColor Yellow
@"
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
"@ | Out-File -FilePath ".mcp.json" -Encoding UTF8

# Criar .env.local
Write-Host "🔧 Criando variáveis de ambiente..." -ForegroundColor Yellow
@"
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
"@ | Out-File -FilePath ".env.local" -Encoding UTF8

# Criar .claude/settings.json
Write-Host "⚙️ Configurando Claude Code..." -ForegroundColor Yellow
@"
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
"@ | Out-File -FilePath ".claude\settings.json" -Encoding UTF8

# Testar conexão com MCPs
Write-Host ""
Write-Host "🧪 Testando conexão com MCPs..." -ForegroundColor Yellow

# Testar Orchestrator
Write-Host -NoNewline "Testando Orchestrator... "
$test = ssh root@$SERVER_IP "docker exec ai-os-orchestrator echo 'OK'" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅" -ForegroundColor Green
} else {
    Write-Host "❌" -ForegroundColor Red
}

# Testar Memory Hub
Write-Host -NoNewline "Testando Memory Hub... "
$test = ssh root@$SERVER_IP "docker exec global-memory-hub echo 'OK'" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅" -ForegroundColor Green
} else {
    Write-Host "❌" -ForegroundColor Red
}

# Testar Context Manager
Write-Host -NoNewline "Testando Context Manager... "
$test = ssh root@$SERVER_IP "docker exec context-manager echo 'OK'" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅" -ForegroundColor Green
} else {
    Write-Host "❌" -ForegroundColor Red
}

# Testar Document Graph
Write-Host -NoNewline "Testando Document Graph... "
$test = ssh root@$SERVER_IP "docker exec document-graph-mcp echo 'OK'" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅" -ForegroundColor Green
} else {
    Write-Host "❌" -ForegroundColor Red
}

# Criar script de teste
Write-Host ""
Write-Host "📝 Criando script de teste..." -ForegroundColor Yellow
@'
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
'@ | Out-File -FilePath "test-mcps.js" -Encoding UTF8

# Instruções finais
Write-Host ""
Write-Host "✅ Setup concluído!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Abra este diretório no Claude Code ou Windsurf"
Write-Host "2. Os MCPs serão carregados automaticamente"
Write-Host "3. Execute o arquivo test-mcps.js para validar a conexão"
Write-Host ""
Write-Host "🔧 Arquivos criados:" -ForegroundColor Yellow
Write-Host "- .mcp.json (configuração dos MCPs)"
Write-Host "- .env.local (variáveis de ambiente)"
Write-Host "- .claude/settings.json (configuração do Claude Code)"
Write-Host "- test-mcps.js (script de teste)"
Write-Host ""
Write-Host "📚 Documentação completa em: docs/CLIENT_SETUP_GUIDE.md" -ForegroundColor Cyan
Write-Host ""