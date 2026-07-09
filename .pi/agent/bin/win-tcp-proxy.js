const net = require('net');
const listenHost = process.argv[2] || '172.17.48.1';
const listenPort = Number(process.argv[3] || 9225);
const targetHost = process.argv[4] || '127.0.0.1';
const targetPort = Number(process.argv[5] || 9224);

const server = net.createServer((client) => {
  const target = net.connect(targetPort, targetHost);
  client.pipe(target);
  target.pipe(client);
  const close = () => { client.destroy(); target.destroy(); };
  client.on('error', close); target.on('error', close);
});
server.listen(listenPort, listenHost, () => {
  console.log(`Proxy listening on ${listenHost}:${listenPort} -> ${targetHost}:${targetPort}`);
});
