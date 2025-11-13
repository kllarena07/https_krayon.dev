const server = Bun.serve({
  port: 3000,
  fetch(req) {
    const url = new URL(req.url);
    const headers = {
      'Content-Type': 'text/html',
      'Cross-Origin-Embedder-Policy': 'require-corp',
      'Cross-Origin-Opener-Policy': 'same-origin',
    };
    
    if (url.pathname === '/') {
      return new Response(Bun.file('./index.html'), {
        headers,
      });
    }
    return new Response('Not Found', { status: 404 });
  },
});

console.log(`Server running on http://localhost:${server.port}`);