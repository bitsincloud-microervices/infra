#!/bin/bash

set -e

echo "🚀 Iniciando script de setup do Kong..."

IP_MAQUINA="192.168.100.197"
echo "🌐 IP informado: $IP_MAQUINA"

echo "🔍 Verificando conectividade com o serviço backend..."
curl --silent --head --fail http://192.168.100.197:9092/bff/clients || {
  echo "❌ O serviço backend não está acessível."
  exit 1
}

echo "📦 Criando service no Kong apontando para o BFF..."
SERVICE_ID=$(curl --silent --request POST \
  --url http://192.168.100.197:8001/services/ \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "bff-clients-service",
    "host": "192.168.100.197",
    "port": 9092,
    "path": "/bff",
    "protocol": "http"
  }' | jq -r '.id')

if [ -z "$SERVICE_ID" ] || [ "$SERVICE_ID" == "null" ]; then
  echo "❌ Falha ao criar serviço!"
  exit 1
fi

echo "✅ Serviço criado. SERVICE_ID: $SERVICE_ID"

echo "🛣️ Criando route para /clients..."
curl --silent --request POST \
  --url http://192.168.100.197:8001/services/$SERVICE_ID/routes \
  --header 'Content-Type: application/json' \
  --data '{
    "paths": ["/clients"],
    "methods": ["POST"],
    "strip_path": true,
    "path_handling": "v1"
  }' | jq .

echo "✨ Configurando plugin request-transformer..."
curl --silent --request POST \
  --url http://192.168.100.197:8001/services/$SERVICE_ID/plugins \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "request-transformer",
    "config": {
      "add": {
        "headers": ["Content-Type:application/json"]
      }
    }
  }' | jq .

echo "🧪 Testando chamada POST via Kong..."
curl --verbose --request POST \
  --url http://192.168.100.197:8000/clients \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "João da Silva 22",
    "email": "joao@email.com"
  }' | jq .

echo "✅ Setup finalizado com sucesso!"