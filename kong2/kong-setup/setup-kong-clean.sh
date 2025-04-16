#!/bin/bash

KONG_ADMIN_URL="http://localhost:8001"

echo "⚙️ Limpando Kong (Plugins, Routes, Services, Consumers)..."

# 1. Deletar todos os plugins
echo "🧹 Deletando todos os plugins..."
PLUGINS=$(curl -s $KONG_ADMIN_URL/plugins | jq -r '.data[].id')
for plugin_id in $PLUGINS; do
  echo "   🔸 Deletando plugin $plugin_id"
  curl -s -X DELETE "$KONG_ADMIN_URL/plugins/$plugin_id"
done

# 2. Listar todas as rotas
echo "📋 Rotas atuais:"
ROUTES=$(curl -s $KONG_ADMIN_URL/routes | jq -r '.data[].id')

for route_id in $ROUTES; do
  echo "   🔸 Deletando rota $route_id"
  curl -s -X DELETE "$KONG_ADMIN_URL/routes/$route_id"
done

# 3. Listar todos os serviços
echo "📋 Serviços atuais:"
SERVICES=$(curl -s $KONG_ADMIN_URL/services | jq -r '.data[].id')

for service_id in $SERVICES; do
  echo "   🔸 Deletando service $service_id"
  curl -s -X DELETE "$KONG_ADMIN_URL/services/$service_id"
done

# 4. Listar todos os consumidores
echo "📋 Consumers atuais:"
CONSUMERS=$(curl -s $KONG_ADMIN_URL/consumers | jq -r '.data[].id')

for consumer_id in $CONSUMERS; do
  echo "   🔸 Deletando consumer $consumer_id"
  curl -s -X DELETE "$KONG_ADMIN_URL/consumers/$consumer_id"
done

echo "✅ Kong completamente limpo!"