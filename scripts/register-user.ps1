# 🚀 AI-OS User Registration Script (PowerShell)
# Registra novo usuário no sistema AI-OS

param(
    [string]$ApiUrl = "https://api.allfluence.ai",
    [string]$AdminDashboard = "https://admin.allfluence.ai"
)

Write-Host "🚀 AI-OS User Registration" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host ""

# Função para ler input
function Read-Input {
    param(
        [string]$Prompt,
        [string]$Default,
        [switch]$Password
    )
    
    if ($Password) {
        return Read-Host -AsSecureString $Prompt | ConvertFrom-SecureString -AsPlainText
    }
    
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

# Função para fazer requisições HTTP
function Invoke-ApiRequest {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [object]$Body,
        [hashtable]$Headers = @{}
    )
    
    $Headers["Content-Type"] = "application/json"
    
    try {
        $params = @{
            Uri = $Uri
            Method = $Method
            Headers = $Headers
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        return $response
    } catch {
        Write-Host "❌ Erro na API: $_" -ForegroundColor Red
        return $null
    }
}

# Menu principal
Write-Host "Escolha uma opção:" -ForegroundColor Yellow
Write-Host "1. Novo usuário (criar conta)"
Write-Host "2. Usuário existente (fazer login)"
Write-Host ""
$choice = Read-Input -Prompt "Opção (1 ou 2)"

if ($choice -eq "1") {
    # REGISTRO DE NOVO USUÁRIO
    Write-Host ""
    Write-Host "📝 Registro de Novo Usuário" -ForegroundColor Green
    Write-Host ""
    
    $email = Read-Input -Prompt "Email"
    $password = Read-Input -Prompt "Senha" -Password
    $confirmPassword = Read-Input -Prompt "Confirme a senha" -Password
    
    if ($password -ne $confirmPassword) {
        Write-Host "❌ As senhas não coincidem!" -ForegroundColor Red
        exit 1
    }
    
    $fullName = Read-Input -Prompt "Nome completo"
    $company = Read-Input -Prompt "Empresa (opcional)"
    $role = Read-Input -Prompt "Cargo (opcional)"
    
    # Escolher tipo de conta
    Write-Host ""
    Write-Host "Tipo de conta:" -ForegroundColor Yellow
    Write-Host "1. Individual (tenant próprio)"
    Write-Host "2. Empresa existente (solicitar acesso)"
    $accountType = Read-Input -Prompt "Tipo (1 ou 2)" -Default "1"
    
    $tenantName = ""
    if ($accountType -eq "1") {
        $tenantName = Read-Input -Prompt "Nome do seu workspace" -Default $company
    } else {
        $tenantName = Read-Input -Prompt "Código da empresa/tenant"
    }
    
    # Registrar usuário
    Write-Host ""
    Write-Host "🔄 Registrando usuário..." -ForegroundColor Yellow
    
    $registrationData = @{
        email = $email
        password = $password
        profile = @{
            fullName = $fullName
            company = $company
            role = $role
        }
        tenant = @{
            type = if ($accountType -eq "1") { "create" } else { "join" }
            name = $tenantName
        }
    }
    
    $response = Invoke-ApiRequest -Uri "$ApiUrl/auth/register" -Method "POST" -Body $registrationData
    
    if ($response) {
        Write-Host "✅ Usuário registrado com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Suas credenciais:" -ForegroundColor Yellow
        Write-Host "USER_ID: $($response.user.id)" -ForegroundColor Cyan
        Write-Host "USER_EMAIL: $email" -ForegroundColor Cyan
        Write-Host "TENANT_ID: $($response.tenant.id)" -ForegroundColor Cyan
        Write-Host "API_TOKEN: $($response.token)" -ForegroundColor Cyan
        
        # Salvar credenciais
        $saveCredentials = Read-Input -Prompt "Salvar credenciais em arquivo? (s/n)" -Default "s"
        if ($saveCredentials -eq "s") {
            $credentials = @{
                USER_ID = $response.user.id
                USER_EMAIL = $email
                TENANT_ID = $response.tenant.id
                API_TOKEN = $response.token
                CREATED_AT = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            }
            
            $credentials | ConvertTo-Json | Out-File -FilePath ".ai-os-credentials.json" -Encoding UTF8
            Write-Host "✅ Credenciais salvas em .ai-os-credentials.json" -ForegroundColor Green
        }
        
        # Verificar email
        Write-Host ""
        Write-Host "📧 Por favor, verifique seu email para ativar sua conta." -ForegroundColor Yellow
        Write-Host "🔗 Admin Dashboard: $AdminDashboard" -ForegroundColor Cyan
    }
    
} else {
    # LOGIN DE USUÁRIO EXISTENTE
    Write-Host ""
    Write-Host "🔐 Login de Usuário Existente" -ForegroundColor Green
    Write-Host ""
    
    $email = Read-Input -Prompt "Email"
    $password = Read-Input -Prompt "Senha" -Password
    
    Write-Host ""
    Write-Host "🔄 Fazendo login..." -ForegroundColor Yellow
    
    $loginData = @{
        email = $email
        password = $password
    }
    
    $response = Invoke-ApiRequest -Uri "$ApiUrl/auth/login" -Method "POST" -Body $loginData
    
    if ($response) {
        Write-Host "✅ Login realizado com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Suas credenciais:" -ForegroundColor Yellow
        Write-Host "USER_ID: $($response.user.id)" -ForegroundColor Cyan
        Write-Host "USER_EMAIL: $email" -ForegroundColor Cyan
        Write-Host "TENANT_ID: $($response.tenant.id)" -ForegroundColor Cyan
        Write-Host "API_TOKEN: $($response.token)" -ForegroundColor Cyan
        
        # Salvar credenciais
        $saveCredentials = Read-Input -Prompt "Salvar credenciais em arquivo? (s/n)" -Default "s"
        if ($saveCredentials -eq "s") {
            $credentials = @{
                USER_ID = $response.user.id
                USER_EMAIL = $email
                TENANT_ID = $response.tenant.id
                API_TOKEN = $response.token
                CREATED_AT = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            }
            
            $credentials | ConvertTo-Json | Out-File -FilePath ".ai-os-credentials.json" -Encoding UTF8
            Write-Host "✅ Credenciais salvas em .ai-os-credentials.json" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Execute ./setup-client.ps1 para configurar o ambiente"
Write-Host "2. As credenciais serão carregadas automaticamente"
Write-Host "3. Teste a conexão com test-mcps.js"
Write-Host ""