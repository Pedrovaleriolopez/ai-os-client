# 🤖 Comandos para Claude Code Executar

## Para Windows (PowerShell)

```powershell
# 1. Verificar se Git está instalado
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git não está instalado. Por favor, instale em: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

# 2. Clonar o repositório (se ainda não clonado)
if (!(Test-Path ".git")) {
    Write-Host "📥 Clonando repositório AI-OS Client..." -ForegroundColor Yellow
    git clone https://github.com/allfluencee/ai-os-client.git .
}

# 3. Verificar política de execução
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq "Restricted") {
    Write-Host "🔓 Habilitando execução de scripts..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

# 4. Executar registro
Write-Host "`n🔐 Iniciando processo de registro/login..." -ForegroundColor Cyan
& .\scripts\register-user.ps1

# 5. Executar setup
Write-Host "`n🚀 Configurando ambiente AI-OS..." -ForegroundColor Cyan
& .\scripts\setup-client.ps1

# 6. Testar conexão
Write-Host "`n🧪 Testando conexão com MCPs..." -ForegroundColor Green
Write-Host "Execute 'node test-mcps.js' para validar a configuração"
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

## Comando Único para Claude Code

### Windows:
```
Por favor execute este script PowerShell para configurar o AI-OS:
git clone https://github.com/allfluencee/ai-os-client.git . ; if ($?) { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force ; .\scripts\register-user.ps1 ; .\scripts\setup-client.ps1 }
```

### Mac/Linux:
```
Por favor execute este comando bash para configurar o AI-OS:
git clone https://github.com/allfluencee/ai-os-client.git . && chmod +x scripts/*.sh && ./scripts/register-user.sh && ./scripts/setup-client.sh
```