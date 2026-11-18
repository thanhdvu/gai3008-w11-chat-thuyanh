import http from 'node:http';

// Class mock proxy: no API key, no dependencies. Error commands fail once,
// then return a successful answer when the same prompt is retried.
const attempts = new Map();
const port = Number(process.env.PORT || 8787);
const server = http.createServer(async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  const send = (code, value) => { res.writeHead(code); res.end(JSON.stringify(value)); };
  if (req.method === 'OPTIONS') return send(204, {});
  if (req.url === '/api/health') return send(200, {ok:true, mode:'mock'});
  if (req.url !== '/api/chat' || req.method !== 'POST') return send(404, {error:'Not found'});
  try {
    let body = ''; for await (const chunk of req) { body += chunk; if (body.length > 16000) return send(413, {error:'Too large'}); }
    const {message} = JSON.parse(body);
    if (typeof message !== 'string' || !message.trim()) return send(400, {error:'Message required'});
    const count = attempts.get(message) || 0; attempts.set(message, count + 1);
    const forced = Number(process.env.FORCE_STATUS || 0);
    if (forced) return send(forced, {error:'Forced test error'});
    if (count === 0 && /^\/(401|429|500)$/.test(message)) return send(Number(message.slice(1)), {error:'Simulated failure; retry this message'});
    const delay = count === 0 && message === '/timeout' ? 31000 : Number(process.env.SLOW_MS || 600);
    setTimeout(() => send(200, {answer:`AI 답변 (MOCK): ${message}`}), delay);
  } catch { send(400, {error:'Invalid JSON'}); }
});
server.listen(port, '127.0.0.1', () => console.log(`MOCK proxy http://localhost:${port}`));
