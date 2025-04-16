#!/bin/bash

# CONFIG
KONG_ADMIN_URL="http://localhost:8001"
SERVICE_NAME="bff-service"
CONSUMER_NAME="cliente123"

echo "🔵 Verificando se o Service $SERVICE_NAME já existe..."
SERVICE_ID=$(curl -s $KONG_ADMIN_URL/services | jq -r --arg NAME "$SERVICE_NAME" '.data[] | select(.name == $NAME) | .id')

if [ -n "$SERVICE_ID" ]; then
  echo "🛑 Service $SERVICE_NAME já existe (id=$SERVICE_ID), deletando..."
  curl -s -X DELETE $KONG_ADMIN_URL/services/$SERVICE_ID
  sleep 1
fi

echo "🔵 Criando service: $SERVICE_NAME (protocol=http, host=host.docker.internal, port=9092)"
curl -s -X POST $KONG_ADMIN_URL/services/ \
  --data "name=$SERVICE_NAME" \
  --data "protocol=http" \
  --data "host=host.docker.internal" \
  --data "port=9092"
sleep 1

echo "🔵 Criando rota /clients"
curl -s -X POST $KONG_ADMIN_URL/services/$SERVICE_NAME/routes \
  --data "paths[]=/bff/clients" \
  --data "strip_path=false" \
  --data "path_handling=v1"
sleep 1

echo "🔵 Criando rota /orders"
curl -s -X POST $KONG_ADMIN_URL/services/$SERVICE_NAME/routes \
  --data "paths[]=/bff//orders" \
  --data "strip_path=false" \
  --data "path_handling=v1"
sleep 1

# Adicionando request-transformer para reescrever os paths
ROUTE_ID_CLIENTS=$(curl -s $KONG_ADMIN_URL/routes | jq -r '.data[] | select(.paths[]=="/clients") | .id')
ROUTE_ID_ORDERS=$(curl -s $KONG_ADMIN_URL/routes | jq -r '.data[] | select(.paths[]=="/orders") | .id')

echo "🔵 Aplicando reescrita de caminho na rota /clients → /bff/clients"
curl -s -X POST $KONG_ADMIN_URL/routes/$ROUTE_ID_CLIENTS/plugins \
  --data "name=request-transformer" \
  --data "config.replace.path=/bff/clients"
sleep 1

echo "🔵 Aplicando reescrita de caminho na rota /orders → /bff/orders"
curl -s -X POST $KONG_ADMIN_URL/routes/$ROUTE_ID_ORDERS/plugins \
  --data "name=request-transformer" \
  --data "config.replace.path=/bff/orders"
sleep 1

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

echo "🔵 Gerando API Key para consumer $CONSUMER_NAME"
API_KEY=$(curl -s -X POST $KONG_ADMIN_URL/consumers/$CONSUMER_NAME/key-auth | jq -r '.key')
echo "✅ API Key gerada: $API_KEY"

echo "🔵 Aplicando plugin key-auth na rota /clients"
curl -s -X POST $KONG_ADMIN_URL/routes/$ROUTE_ID_CLIENTS/plugins \
  --data "name=key-auth"
sleep 1

echo "🔵 Aplicando plugin key-auth na rota /orders"
curl -s -X POST $KONG_ADMIN_URL/routes/$ROUTE_ID_ORDERS/plugins \
  --data "name=key-auth"
sleep 1

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
echo "   http://localhost:8000/clients"
echo "   http://localhost:8000/orders"
