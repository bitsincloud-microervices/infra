Ubuntu/Debian: 
sudo apt update
sudo apt install jq

CentOS/RHEL/Amazon Linux 2:
sudo yum install jq

Fedora:
sudo dnf install jq

MacOS (com brew):
brew install jq

choco install jq

==================
## Export Default Configuration
bash```
    $ curl -s localhost:8001 | jq '.configuration' > output/configuration-default.json

## Set Rate Limit Globbaly to 60 requests per minute.

curl -X POST http://localhost:8001/plugins \
  --data name=rate-limiting \
  --data config.minute=60 \
  --data config.policy=local -o output/admin-api-rate-limit-global.json


## Set Default Proxy Cache to 30 seconds

curl -X POST http://localhost:8001/plugins \
  --data "name=proxy-cache" \
  --data "config.request_method=GET" \
  --data "config.response_code=200" \
  --data "config.content_type=application/json; charset=utf-8" \
  --data "config.cache_ttl=30" \
  --data "config.strategy=memory" -o output/admin-api-proxy-cache-global.json

## Creating Admin API Service

curl --request POST \
  --url http://localhost:8001/services \
  --data name=admin-api-service \
  --data url='http://localhost:8001' -o output/admin-api-service.json

## Creating Admin API Route

curl --request POST \
  --url http://localhost:8001/services/admin-api-service/routes \
  --data 'paths[]=/admin-api' \
  --data name=admin-api-route -o output/admin-api-route.json

## Enable Key Auth on Admin API Service

curl --request POST \
    --url http://localhost:8001/services/admin-api-service/plugins \
    --header 'Content-Type: application/json' \
    --header 'accept: application/json' \
    --data '{"name":"key-auth","config":{"key_names":["api-key"],"key_in_query":false}}' -o output/admin-api-key.json

## Create Admin API Consumer

curl --request POST \
  --url http://localhost:8001/consumers \
  --header 'Content-Type: application/json' \
  --header 'accept: application/json' \
  --data '{"username":"administrator","custom_id":"administrator"}' -o output/admin-api-consumer.json


## Create Admin API Key

curl -X POST http://localhost:8001/consumers/administrator/key-auth -o output/admin-api-consumer-key.json


Parar todos os containers:

bash
Copy
Edit
docker stop $(docker ps -aq)
Remover todos os containers:

bash
Copy
Edit
docker rm -f $(docker ps -aq)
Remover todos os volumes:

bash
Copy
Edit
docker volume rm $(docker volume ls -q)

docker system prune -a --volumes -f


docker-compose up -d konga

docker-compose stop konga
docker-compose rm -f konga

docker-compose stop konga
docker-compose rm -f konga
docker-compose up -d konga

docker exec -it kong-database psql -U kong -c "CREATE DATABASE kong;"
  # https://dev.to/nasrulhazim/setup-kong-gateway-with-docker-4m6l

===================================================================

1. Criar o Service no Kong
curl --request POST \
  --url http://localhost:8001/services/ \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "bff-clients-service",
    "url": "http://host.docker.internal:9092/bff/clients"
  }'


 2. Criar a Route no Kong

curl --request POST \
  --url http://localhost:8001/services/bff-clients-service/routes \
  --header 'Content-Type: application/json' \
  --data '{
    "paths": ["/clients"],
    "methods": ["POST"]
  }'

==
curl --request POST \
  --url http://localhost:8001/services/bff-clients-service/plugins \
  --header 'Content-Type: application/json' \
  --data '{
    "name": "request-transformer",
    "config": {
      "add": {
        "headers": ["Content-Type:application/json"]
      }
    }
  }'

===
3. Testar tudo
curl --request POST \
  --url http://localhost:8000/clients \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --data '{
    "name": "João da Silva 22",
    "email": "joao@email.com"
  }'

==============
curl --request PATCH \
  --url http://localhost:8001/plugins/0a1b66f2-4c69-4ac5-8c03-26c9fb1eef7c \
  --header 'Content-Type: application/json' \
  --data '{
    "config": {
      "add": {
        "headers": [
          "Content-Type:application/json"
        ]
      }
    }
  }'



----
curl -i -X DELETE http://localhost:8001/services/bff-clients-service

curl -i -X DELETE http://localhost:8001/routes/b685a754-bc60-4ec6-8e7f-32f7545f6812

curl -i -X DELETE http://localhost:8001/services/bff-clients-service

====================================

192.168.100.197

chmod +x setup_kong.sh
==========================================

O que funcionou para o kong
--
curl -i -X POST http://localhost:8001/consumers/ \
  --data "username=cliente123"

==============
➡️ API Key para testes: Usr6K3ixaqq7LrHKyGbjKN5NBox8vZid
➡️ Header para requisição: apikey: Usr6K3ixaqq7LrHKyGbjKN5NBox8vZid


chmod +x list-kong.sh
./list-kong.sh

➡️ API Key para testes: VG7ZC2EInBaxUy93zYOCxqwqSI7C4sl9
➡️ Headers: apikey: VG7ZC2EInBaxUy93zYOCxqwqSI7C4sl9


curl -s http://localhost:8001/routes | jq
curl -X DELETE http://localhost:8001/routes/ea29ea89-4894-4500-997a-6e7df12300ee
curl -X DELETE http://localhost:8001/services/bff-service

==

docker run -d -p 1337:1337 \
  --name konga \
  -e NODE_ENV=development \
  pantsel/konga

---
http://localhost:1337
http://localhost:1337
Campo	Valor
Name	Kong Local
Kong Admin URL	http://localhost:8001
Health check endpoint	Deixa vazio ou /

==
docker-compose -f docker-compose.konga.yml up -d

k6 run rate-limit-test.js
