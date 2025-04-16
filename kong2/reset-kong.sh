#!/bin/bash

# CONFIG
KONG_ADMIN_URL="http://localhost:8001"

echo "🔴 Deletando todos os Consumers..."
for consumer in $(curl -s $KONG_ADMIN_URL/consumers | jq -r '.data[].id'); do
  curl -s -X DELETE $KONG_ADMIN_URL/consumers/$consumer
done

echo "🔴 Deletando todos os Services e suas Routes..."
for service in $(curl -s $KONG_ADMIN_URL/services | jq -r '.data[].id'); do
  curl -s -X DELETE $KONG_ADMIN_URL/services/$service
done

echo "🔴 Deletando todos os Routes restantes (caso tenham ficado órfãs)..."
for route in $(curl -s $KONG_ADMIN_URL/routes | jq -r '.data[].id'); do
  curl -s -X DELETE $KONG_ADMIN_URL/routes/$route
done

echo "🔴 Deletando todos os Plugins restantes..."
for plugin in $(curl -s $KONG_ADMIN_URL/plugins | jq -r '.data[].id'); do
  curl -s -X DELETE $KONG_ADMIN_URL/plugins/$plugin
done

echo ""
echo "✅ Reset do Kong concluído!"
ch