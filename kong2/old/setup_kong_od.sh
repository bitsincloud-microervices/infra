#!/bin/bash

set -e

echo "🚀 Iniciando script de setup do Kong..."

# Detectando IP da máquina
echo "🌐 Detectando IP da máquina automaticamente..."
IP_MAQUINA=192.168.100.197 #$(ipconfig | awk '/Adaptador de LAN sem fio Wi-Fi|Wireless LAN adapter Wi-Fi/ {getline; getline; print}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}')
echo "🌐 IP informado: $IP_MAQUINA"

# Verificando conectividade com o backend
echo "🔍 Verificando conectividade com o serviço backend..."
curl --silent --head --fail http://192.168.100.197:9092/bff/clients || {
  echo "❌ O serviço backend não está acessível em http://192.168.100.197:9092/bff/clients."
  exit 1
}

# Criar Service no Kong e pegar ID automaticamente
echo "📦 Criando service no Kong apontando para o BFF..."
SERVICE_ID=$(curl --silent --request POST \
  --url http://192.168.100.197:8001/services/ \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "bff-clients-service",
    "host": "192.168.100.197",
    "port": 9092,
    "path": "/bff/clients",
    "protocol": "http"
  }' | jq -r '.id')

if [ -z "$SERVICE_ID" ]; then
  echo "❌ Falha ao criar o serviço no Kong. Verifique as configurações e tente novamente."
  exit 1
fi
echo "✅ Serviço criado com sucesso. SERVICE_ID: $SERVICE_ID"

# Criar Route no Kong usando o ID capturado
echo "🛣️ Criando route para /clients..."
curl --silent --request POST \
  --url http://192.168.100.197:8001/services/bff-clients-service/routes \
  --header 'Content-Type: application/json' \
  --data '{
    "paths": ["/clients"],
    "methods": ["POST"],
    "strip_path": true,
    "path_handling": "v1"
  }' | jq .

# Criar plugin request-transformer
echo "✨ Configurando plugin request-transformer para adicionar Content-Type: application/json..."
curl --silent --request POST \
  --url http://192.168.100.197:8001/services/bff-clients-service/plugins \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "request-transformer",
    "config": {
      "add": {
        "headers": [
          "Content-Type:application/json"
        ]
      }
    }
  }' | jq .

# Testar o POST via Kong
echo "🧪 Testando chamada POST para /clients via Kong..."
curl --verbose --request POST \
  --url http://192.168.100.197:8000/clients \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "João da Silva 22",
    "email": "joao@email.com"
  }' | jq .

echo "✅ Setup finalizado!"