#!/bin/bash

# CONFIG
KONG_ADMIN_URL="http://localhost:8001"
BFF_URL="http://host.docker.internal:9092/bff" # AQUI já definimos o /bff
SERVICE_NAME="bff-service"
CONSUMER_NAME="cliente123"

echo "🔵 Criando service: $SERVICE_NAME"
curl -s -X POST $KONG_ADMIN_URL/services/ \
  --data "name=$SERVICE_NAME" \
  --data "url=$BFF_URL"

echo "🔵 Criando rota /clients"
curl -s -X POST $KONG_ADMIN_URL/services/$SERVICE_NAME/routes \
  --data "paths[]=/clients" \
  --data "strip_path=true"

echo "🔵 Criando rota /orders"
curl -s -X POST $KONG_ADMIN_URL/services/$SERVICE_NAME/routes \
  --data "paths[]=/orders" \
  --data "strip_path=true"

echo "🔵 Criando consumer: $CONSUMER_NAME"
curl -s -X POST $KONG_ADMIN_URL/consumers/ \
  --data "username=$CONSUMER_NAME"

echo "🔵 Gerando API Key para consumer $CONSUMER_NAME"
API_KEY=$(curl -s -X POST $KONG_ADMIN_URL/consumers/$CONSUMER_NAME/key-auth | jq -r '.key')
echo "✅ API Key gerada: $API_KEY"

# Pegando o ID da rota /clients
ROUTE_ID_CLIENTS=$(curl -s $KONG_ADMIN_URL/routes | jq -r '.data[] | select(.paths[]=="/clients") | .id')

# Pegando o ID da rota /orders
ROUTE_ID_ORDERS=$(curl -s $KONG_ADMIN_URL/routes | jq -r '.data[] | select(.paths[]=="/orders") | .id')

echo "🔵 Aplicando plugin key-auth na rota /clients"
curl -s -X POST $KONG_ADMIN_URL/routes/$ROUTE_ID_CLIENTS/plugins \
  --data "name=key-auth"

echo "🔵 Aplicando plugin key-auth na rota /orders"
curl -s -X POST $KONG_ADMIN_URL/routes/$ROUTE_ID_ORDERS/plugins \
  --data "name=key-auth"

echo "🔵 Aplicando rate limit 5/minuto para consumer $CONSUMER_NAME"
curl -s -X POST $KONG_ADMIN_URL/consumers/$CONSUMER_NAME/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=5" \
  --data "config.policy=local"

echo ""
echo "✅ Setup finalizado!"
echo "➡️ API Key para testes: $API_KEY"
echo "➡️ Header para requisição: apikey: $API_KEY"
echo "➡️ URLs para testar via Kong:"
echo "   http://localhost:8000/clients"
echo "   http://localhost:8000/orders"
