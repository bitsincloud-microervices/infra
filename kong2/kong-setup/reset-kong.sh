#!/bin/bash

KONG_ADMIN_URL="http://localhost:8001"

echo "🔴 Deletando todos os Consumers..."
for consumer in $(curl -s $KONG_ADMIN_URL/consumers | jq -r '.data[].id'); do
  curl -s -X DELETE $KONG_ADMIN_URL/consumers/$consumer
done

echo "🔴 Deletando todos os Services..."
for service in $(curl -s $KONG_ADMIN_URL/services | jq -r '.data[].id'); do
  curl -s -X DELETE $KONG_ADMIN_URL/services/$service
done

echo "🔴 Deletando todas as Rotas órfãs..."
for route in $(curl -s $KONG_ADMIN_URL/routes | jq -r '.data[].id'); do
  curl -s -X DELETE $KONG_ADMIN_URL/routes/$route
done

echo "🔴 Deletando todos os Plugins órfãos..."
for plugin in $(curl -s $KONG_ADMIN_URL/plugins | jq -r '.data[].id'); do
  curl -s -X DELETE $KONG_ADMIN_URL/plugins/$plugin
done

echo ""
echo "✅ Reset completo do Kong!"