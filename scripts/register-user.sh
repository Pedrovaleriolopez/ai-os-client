#!/bin/bash

# 🚀 AI-OS User Registration Script
# Registra novo usuário no sistema AI-OS

set -e

API_URL="${API_URL:-https://api.allfluence.ai}"
ADMIN_DASHBOARD="${ADMIN_DASHBOARD:-https://admin.allfluence.ai}"

echo "🚀 AI-OS User Registration"
echo "=========================="
echo ""

# Função para ler input
read_input() {
    local prompt="$1"
    local default="$2"
    local password="$3"
    
    if [ "$password" = "password" ]; then
        read -s -p "$prompt: " input
        echo ""
    else
        if [ -n "$default" ]; then
            read -p "$prompt [$default]: " input
            if [ -z "$input" ]; then
                input="$default"
            fi
        else
            read -p "$prompt: " input
        fi
    fi
    
    echo "$input"
}

# Função para fazer requisições HTTP
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    if [ -n "$data" ]; then
        curl -s -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$API_URL$endpoint"
    else
        curl -s -X "$method" \
            -H "Content-Type: application/json" \
            "$API_URL$endpoint"
    fi
}

# Menu principal
echo "Escolha uma opção:"
echo "1. Novo usuário (criar conta)"
echo "2. Usuário existente (fazer login)"
echo ""
choice=$(read_input "Opção (1 ou 2)" "")

if [ "$choice" = "1" ]; then
    # REGISTRO DE NOVO USUÁRIO
    echo ""
    echo "📝 Registro de Novo Usuário"
    echo ""
    
    email=$(read_input "Email" "")
    password=$(read_input "Senha" "" "password")
    confirm_password=$(read_input "Confirme a senha" "" "password")
    
    if [ "$password" != "$confirm_password" ]; then
        echo "❌ As senhas não coincidem!"
        exit 1
    fi
    
    full_name=$(read_input "Nome completo" "")
    company=$(read_input "Empresa (opcional)" "")
    role=$(read_input "Cargo (opcional)" "")
    
    # Escolher tipo de conta
    echo ""
    echo "Tipo de conta:"
    echo "1. Individual (tenant próprio)"
    echo "2. Empresa existente (solicitar acesso)"
    account_type=$(read_input "Tipo (1 ou 2)" "1")
    
    if [ "$account_type" = "1" ]; then
        tenant_name=$(read_input "Nome do seu workspace" "${company:-MyWorkspace}")
    else
        tenant_name=$(read_input "Código da empresa/tenant" "")
    fi
    
    # Registrar usuário
    echo ""
    echo "🔄 Registrando usuário..."
    
    registration_data=$(cat <<EOF
{
    "email": "$email",
    "password": "$password",
    "profile": {
        "fullName": "$full_name",
        "company": "$company",
        "role": "$role"
    },
    "tenant": {
        "type": "$([ "$account_type" = "1" ] && echo "create" || echo "join")",
        "name": "$tenant_name"
    }
}
EOF
)
    
    response=$(api_request "POST" "/auth/register" "$registration_data")
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "✅ Usuário registrado com sucesso!"
        echo ""
        echo "📋 Suas credenciais:"
        
        # Parse JSON response
        user_id=$(echo "$response" | grep -o '"user":{[^}]*"id":"[^"]*"' | sed 's/.*"id":"\([^"]*\)".*/\1/')
        tenant_id=$(echo "$response" | grep -o '"tenant":{[^}]*"id":"[^"]*"' | sed 's/.*"id":"\([^"]*\)".*/\1/')
        api_token=$(echo "$response" | grep -o '"token":"[^"]*"' | sed 's/.*"token":"\([^"]*\)".*/\1/')
        
        echo "USER_ID: $user_id"
        echo "USER_EMAIL: $email"
        echo "TENANT_ID: $tenant_id"
        echo "API_TOKEN: $api_token"
        
        # Salvar credenciais
        save_credentials=$(read_input "Salvar credenciais em arquivo? (s/n)" "s")
        if [ "$save_credentials" = "s" ]; then
            cat > .ai-os-credentials.json <<EOF
{
    "USER_ID": "$user_id",
    "USER_EMAIL": "$email",
    "TENANT_ID": "$tenant_id",
    "API_TOKEN": "$api_token",
    "CREATED_AT": "$(date -u +"%Y-%m-%d %H:%M:%S")"
}
EOF
            echo "✅ Credenciais salvas em .ai-os-credentials.json"
        fi
        
        # Verificar email
        echo ""
        echo "📧 Por favor, verifique seu email para ativar sua conta."
        echo "🔗 Admin Dashboard: $ADMIN_DASHBOARD"
    else
        echo "❌ Erro ao registrar usuário. Verifique os dados e tente novamente."
        exit 1
    fi
    
else
    # LOGIN DE USUÁRIO EXISTENTE
    echo ""
    echo "🔐 Login de Usuário Existente"
    echo ""
    
    email=$(read_input "Email" "")
    password=$(read_input "Senha" "" "password")
    
    echo ""
    echo "🔄 Fazendo login..."
    
    login_data=$(cat <<EOF
{
    "email": "$email",
    "password": "$password"
}
EOF
)
    
    response=$(api_request "POST" "/auth/login" "$login_data")
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "✅ Login realizado com sucesso!"
        echo ""
        echo "📋 Suas credenciais:"
        
        # Parse JSON response
        user_id=$(echo "$response" | grep -o '"user":{[^}]*"id":"[^"]*"' | sed 's/.*"id":"\([^"]*\)".*/\1/')
        tenant_id=$(echo "$response" | grep -o '"tenant":{[^}]*"id":"[^"]*"' | sed 's/.*"id":"\([^"]*\)".*/\1/')
        api_token=$(echo "$response" | grep -o '"token":"[^"]*"' | sed 's/.*"token":"\([^"]*\)".*/\1/')
        
        echo "USER_ID: $user_id"
        echo "USER_EMAIL: $email"
        echo "TENANT_ID: $tenant_id"
        echo "API_TOKEN: $api_token"
        
        # Salvar credenciais
        save_credentials=$(read_input "Salvar credenciais em arquivo? (s/n)" "s")
        if [ "$save_credentials" = "s" ]; then
            cat > .ai-os-credentials.json <<EOF
{
    "USER_ID": "$user_id",
    "USER_EMAIL": "$email",
    "TENANT_ID": "$tenant_id",
    "API_TOKEN": "$api_token",
    "CREATED_AT": "$(date -u +"%Y-%m-%d %H:%M:%S")"
}
EOF
            echo "✅ Credenciais salvas em .ai-os-credentials.json"
        fi
    else
        echo "❌ Erro ao fazer login. Verifique suas credenciais."
        exit 1
    fi
fi

echo ""
echo "📋 Próximos passos:"
echo "1. Execute ./setup-client.sh para configurar o ambiente"
echo "2. As credenciais serão carregadas automaticamente"
echo "3. Teste a conexão com test-mcps.js"
echo ""