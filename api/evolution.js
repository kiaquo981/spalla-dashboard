export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  try {
    const path = req.url.replace('/api/evolution', '');
    const url = `https://evolution.manager01.feynmanproject.com${path}`;

    console.log('[Evolution] Request:', { method: req.method, path, url });

    const response = await fetch(url, {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '07826A779A5C-4E9C-A978-DBCD5F9E4C97',
      },
      body: req.method !== 'GET' ? JSON.stringify(req.body) : undefined,
    });

    console.log('[Evolution] Response status:', response.status, 'Content-Type:', response.headers.get('content-type'));

    // Check if response is JSON or HTML
    const contentType = response.headers.get('content-type') || '';
    let data;

    if (contentType.includes('application/json')) {
      data = await response.json();
      console.log('[Evolution] Parsed JSON response');
    } else {
      // If not JSON, get raw text
      const text = await response.text();
      console.log('[Evolution] Raw response (first 200 chars):', text.substring(0, 200));

      if (response.ok) {
        // If successful but not JSON, try to parse it anyway
        try {
          data = JSON.parse(text);
        } catch (e) {
          console.error('[Evolution] Failed to parse non-JSON response as JSON');
          return res.status(500).json({
            error: 'Evolution API returned non-JSON response',
            statusCode: response.status,
            contentType: contentType,
            preview: text.substring(0, 500)
          });
        }
      } else {
        // Error response (likely HTML error page)
        return res.status(response.status).json({
          error: 'Evolution API error',
          statusCode: response.status,
          contentType: contentType,
          preview: text.substring(0, 500)
        });
      }
    }

    res.status(response.status).json(data);
  } catch (e) {
    console.error('[Evolution] Fetch error:', e.message);
    res.status(500).json({ error: e.message, type: 'fetch_error' });
  }
}
