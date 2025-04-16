#!/bin/bash

# CONFIG
API_KEY="VG7ZC2EInBaxUy93zYOCxqwqSI7C4sl9"
KONG_PROXY_URL="http://localhost:8000"

# As rotas que você cadastrou
ROUTES=("clients" "orders")

echo "🛠 Testando rotas configuradas..."

for route in "${ROUTES[@]}"; do
  echo "🔵 Testando: $KONG_PROXY_URL/$route"
  response=$(curl -s -o /dev/null -w "%{http_code}" -H "apikey: $API_KEY" "$KONG_PROXY_URL/$route")

  if [ "$response" == "200" ]; then
    echo "✅ $route -> Sucesso (HTTP 200)"
  elif [ "$response" == "401" ]; then
    echo "🔒 $route -> Falha de autenticação (HTTP 401)"
  elif [ "$response" == "404" ]; then
    echo "❌ $route -> Não encontrado (HTTP 404)"
  else
    echo "⚠️ $route -> HTTP $response"
  fi

  sleep 1
done

echo "✅ Teste finalizado!"
