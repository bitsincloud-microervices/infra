import http from 'k6/http';
import { check, sleep } from 'k6';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

export let options = {
  vus: 20,
  duration: '10s',
  //iterations: 10, // Aumente conforme necessário para testar o rate limit
};

export default function () {
  // 🔹 Endpoint /clients
  const uniqueId = uuidv4();
  const clientPayload = JSON.stringify({
    name: `Teste Rate ${uniqueId}`,
    email: `user_${uniqueId}teste@email.com`,
  });

  const clientParams = {
    headers: {
      'Content-Type': 'application/json',
      'apikey': '550e8400-e29b-41d4-a716-446655440000',
    },
  };

  const clientRes = http.post('http://localhost:9191/clients', clientPayload, clientParams);

  check(clientRes, {
    'client: status is 2xx': (r) => r.status >= 200 && r.status < 204,
    'client: status is 429': (r) => r.status === 429,
  });

  console.log(`CLIENT status: ${clientRes.status}`);
  console.log(`CLIENT response: ${clientRes.body}`);

  // 🔹 Endpoint /orders
  const orderPayload = JSON.stringify({
    orderId: uuidv4(), // Gera novo UUID a cada requisição
    amount: 100.99,
  });

  const orderParams = {
    headers: {
      'Content-Type': 'application/json',
      'apikey': '550e8400-e29b-41d4-a716-446655440000',
    },
  };

  const orderRes = http.post('http://localhost:9191/orders', orderPayload, orderParams);

  check(orderRes, {
    'order: status is 2xx': (r) =>r.status >= 200 && r.status < 204,
    'order: status is 429': (r) => r.status === 429,
  });

  console.log(`ORDER status: ${orderRes.status}`);
  console.log(`ORDER response: ${orderRes.body}`);

  sleep(0.1); // Pequeno delay para não travar a API em ambientes locais
}
