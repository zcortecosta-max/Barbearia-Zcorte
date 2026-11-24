// Service worker mínimo: deixa o painel instalável. Não guarda nada em cache, então os dados são sempre atuais.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(self.clients.claim()));
self.addEventListener('fetch', () => {});
