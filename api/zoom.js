const ZOOM_ACCOUNT_ID = 'DXq-KNA5QuSpcjG6UeUs0Q';
const ZOOM_CLIENT_ID = 'fvNVWKX_SumngWI1kQNhg';
const ZOOM_CLIENT_SECRET = 'zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g';

async function getZoomToken() {
  const creds = Buffer.from(`${ZOOM_CLIENT_ID}:${ZOOM_CLIENT_SECRET}`).toString('base64');
  const response = await fetch(
    `https://zoom.us/oauth/token?grant_type=account_credentials&account_id=${ZOOM_ACCOUNT_ID}`,
    {
      method: 'POST',
      headers: { 'Authorization': `Basic ${creds}` },
    }
  );
  const data = await response.json();
  return data.access_token;
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(200).end();

  try {
    const { topic, start_time, duration } = req.body;
    const token = await getZoomToken();

    const response = await fetch('https://api.zoom.us/v2/users/me/meetings', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        topic,
        type: 2,
        start_time,
        duration,
        timezone: 'America/Sao_Paulo',
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('[Zoom Error]', data);
      throw new Error(data.message || 'Zoom API error');
    }

    res.json({ success: true, id: data.id, join_url: data.join_url });
  } catch (e) {
    console.error('[Zoom Exception]', e);
    res.status(500).json({ error: e.message });
  }
}
