#!/bin/bash

# CONFIGURAÇÕES
KONG_ADMIN_URL="http://localhost:8001"
SERVICE_NAME="bff-service"
CONSUMER_NAME="cliente123"

# Rotas que você quer criar
ROUTES=("clients" "orders") # <-- Adicione suas rotas aqui!

# 🔵 Função para criar uma rota
create_route() {
  local route_name=$1

  echo "🔵 Criando rota /$route_name"
  local route_response=$(curl -s -X POST $KONG_ADMIN_URL/services/$SERVICE_NAME/routes \
    --data "paths[]=/$route_name" \
    --data "strip_path=false" \
    --data "path_handling=v1")

  sleep 1

  local route_id=$(echo $route_response | jq -r '.id')

  if [ -z "$route_id" ] || [ "$route_id" == "null" ]; then
    echo "❌ Erro: Não foi possível criar a rota /$route_name"
    echo "Detalhe: $route_response"
    exit 1
  fi

  echo "🔵 Aplicando reescrita /$route_name → /bff/$route_name"
  curl -s -X POST $KONG_ADMIN_URL/routes/$route_id/plugins \
    -H "Content-Type: application/json" \
    -d '{"name": "request-transformer", "config": {"replace": {"uri": "/bff/'$route_name'"}}}'

  sleep 1

  echo "🔵 Aplicando key-auth na rota /$route_name"
  curl -s -X POST $KONG_ADMIN_URL/routes/$route_id/plugins \
    --data "name=key-auth"

  sleep 1
}

# 🔵 Criação do Service
echo "🔵 Verificando se o Service $SERVICE_NAME já existe..."
SERVICE_ID=$(curl -s $KONG_ADMIN_URL/services | jq -r --arg NAME "$SERVICE_NAME" '.data[] | select(.name == $NAME) | .id')

if [ -n "$SERVICE_ID" ]; then
  echo "🛑 Service $SERVICE_NAME já existe (id=$SERVICE_ID), deletando..."
  curl -s -X DELETE $KONG_ADMIN_URL/services/$SERVICE_ID
  sleep 1
fi

echo "🔵 Criando service: $SERVICE_NAME"
curl -s -X POST $KONG_ADMIN_URL/services/ \
  --data "name=$SERVICE_NAME" \
  --data "protocol=http" \
  --data "host=host.docker.internal" \
  --data "port=9092"

sleep 1

# 🔵 Criando as rotas dinamicamente
for route in "${ROUTES[@]}"; do
  create_route $route
done

# 🔵 Consumer
echo "🔵 Criando consumer: $CONSUMER_NAME (se não existir)"
CONSUMER_ID=$(curl -s $KONG_ADMIN_URL/consumers | jq -r --arg NAME "$CONSUMER_NAME" '.data[] | select(.username == $NAME) | .id')

if [ -z "$CONSUMER_ID" ]; then
  curl -s -X POST $KONG_ADMIN_URL/consumers/ \
    --data "username=$CONSUMER_NAME"
  echo "✅ Consumer $CONSUMER_NAME criado."
else
  echo "⚠️ Consumer $CONSUMER_NAME já existe."
fi

sleep 1

# 🔵 Gerando API Key
echo "🔵 Gerando API Key para consumer $CONSUMER_NAME"
API_KEY=$(curl -s -X POST $KONG_ADMIN_URL/consumers/$CONSUMER_NAME/key-auth | jq -r '.key')
echo "✅ API Key gerada: $API_KEY"

sleep 1

# 🔵 Aplicando Rate Limiting
echo "🔵 Aplicando rate limit 5/minuto para consumer $CONSUMER_NAME"
curl -s -X POST $KONG_ADMIN_URL/consumers/$CONSUMER_NAME/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=5" \
  --data "config.policy=local"

echo ""
echo "✅ Setup finalizado!"
echo "➡️ API Key para testes: $API_KEY"
echo "➡️ Headers: apikey: $API_KEY"
echo "➡️ URLs para testar:"

for route in "${ROUTES[@]}"; do
  echo "   http://localhost:8000/$route"
done
