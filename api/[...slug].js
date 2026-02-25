export default async function handler(req, res) {
  const slug = req.query.slug;
  const path = Array.isArray(slug) ? '/' + slug.join('/') : '/' + (slug || '');

  // Only handle /api/evolution/* requests
  if (!path.startsWith('/evolution')) {
    return res.status(404).json({ error: 'Not found', path });
  }

  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  try {
    const url = `https://evolution.manager01.feynmanproject.com${path}`;
    console.log('[Evolution] Proxying:', { method: req.method, path, url });

    const body = req.method !== 'GET' && req.method !== 'HEAD'
      ? (typeof req.body === 'string' ? req.body : JSON.stringify(req.body))
      : undefined;

    const response = await fetch(url, {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '07826A779A5C-4E9C-A978-DBCD5F9E4C97',
      },
      body: body,
    });

    const text = await response.text();
    console.log('[Evolution] Response:', {
      status: response.status,
      contentType: response.headers.get('content-type'),
    });

    res.setHeader('Content-Type', response.headers.get('content-type') || 'application/json');
    res.status(response.status);
    res.end(text);
  } catch (e) {
    console.error('[Evolution] Error:', e.message);
    res.status(502).json({ error: e.message });
  }
}
