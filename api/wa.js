export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { action, remoteJid, limit, number, text } = req.body;

  if (!action) {
    return res.status(400).json({ error: 'Missing action' });
  }

  try {
    let url, body;

    if (action === 'findChats') {
      url = `https://evolution.manager01.feynmanproject.com/chat/findChats/produ02`;
      body = JSON.stringify({});
    } else if (action === 'sendText') {
      if (!number || !text) {
        return res.status(400).json({ error: 'Missing number or text' });
      }
      url = `https://evolution.manager01.feynmanproject.com/message/sendText/produ02`;
      body = JSON.stringify({ number, text });
      console.log(`[WA] sendText to:`, number);
    } else if (action === 'findMessages') {
      if (!remoteJid) {
        return res.status(400).json({ error: 'Missing remoteJid' });
      }
      url = `https://evolution.manager01.feynmanproject.com/chat/findMessages/produ02`;
      body = JSON.stringify({ where: { key: { remoteJid } }, limit: limit || 50 });
      console.log(`[WA] findMessages for remoteJid:`, remoteJid);
    } else {
      return res.status(400).json({ error: 'Unknown action: ' + action });
    }

    console.log(`[WA] ${action} from Vercel to Evolution API`);

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': '07826A779A5C-4E9C-A978-DBCD5F9E4C97',
      },
      body: body,
    });

    const data = await response.text();
    console.log(`[WA] ${action} response:`, {
      status: response.status,
      dataLength: data.length,
      isJson: data.startsWith('{') || data.startsWith('['),
      preview: data.substring(0, 100),
    });

    // Send back exactly what Evolution API returns
    res.status(response.status);
    res.setHeader('Content-Type', response.headers.get('content-type') || 'application/json');
    res.end(data);
  } catch (e) {
    console.error('[WA] Error:', e.message);
    res.status(502).json({ error: e.message });
  }
}
