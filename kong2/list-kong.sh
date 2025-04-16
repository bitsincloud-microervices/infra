#!/bin/bash

KONG_ADMIN_URL="http://localhost:8001"

echo "=============================="
echo "🔵 LISTANDO SERVICES"
echo "=============================="
curl -s $KONG_ADMIN_URL/services | jq '.data[] | {id: .id, name: .name, url: .url}'
echo ""

echo "=============================="
echo "🔵 LISTANDO ROUTES"
echo "=============================="
curl -s $KONG_ADMIN_URL/routes | jq '.data[] | {id: .id, paths: .paths, service_id: .service.id, strip_path: .strip_path}'
echo ""

echo "=============================="
echo "🔵 LISTANDO CONSUMERS"
echo "=============================="
curl -s $KONG_ADMIN_URL/consumers | jq '.data[] | {id: .id, username: .username}'
echo ""

echo "=============================="
echo "🔵 LISTANDO PLUGINS"
echo "=============================="
curl -s $KONG_ADMIN_URL/plugins | jq '.data[] | {id: .id, name: .name, service_id: .service.id, route_id: .route.id, consumer_id: .consumer.id}'
echo ""
