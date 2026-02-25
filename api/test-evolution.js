export default async function handler(req, res) {
  const { endpoint = 'chat/findChats', instance = 'produ02' } = req.query;

  console.log('[Test Evolution] Request:', { endpoint, instance });

  try {
    const evolutionUrl = `https://evolution.manager01.feynmanproject.com/${endpoint}/${instance}`;
    console.log('[Test Evolution] Calling:', evolutionUrl);

    const response = await fetch(evolutionUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'apikey': '07826A779A5C-4E9C-A978-DBCD5F9E4C97',
      },
    });

    console.log('[Test Evolution] Response status:', response.status);
    console.log('[Test Evolution] Response headers:', {
      'content-type': response.headers.get('content-type'),
      'content-length': response.headers.get('content-length'),
    });

    const text = await response.text();
    console.log('[Test Evolution] Raw response (first 500 chars):', text.substring(0, 500));

    // Try to detect what we got
    const isHtml = text.includes('<!DOCTYPE') || text.includes('<html') || text.includes('<head');
    const isJson = text.trim().startsWith('{') || text.trim().startsWith('[');

    let parsed;
    try {
      parsed = JSON.parse(text);
    } catch (e) {
      parsed = null;
    }

    res.status(200).json({
      success: response.ok,
      statusCode: response.status,
      contentType: response.headers.get('content-type'),
      isHtml,
      isJson,
      isValidJson: !!parsed,
      rawLength: text.length,
      preview: text.substring(0, 500),
      fullResponse: text.length < 2000 ? text : null,
      parsed: parsed,
    });
  } catch (e) {
    console.error('[Test Evolution] Error:', e.message);
    res.status(500).json({
      error: e.message,
      type: 'fetch_error',
    });
  }
}
