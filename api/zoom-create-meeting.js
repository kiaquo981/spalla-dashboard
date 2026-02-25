import fetch from 'node-fetch';

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
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { topic, start_time, duration, email } = req.body;
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
        settings: {
          host_video: true,
          participant_video: true,
          join_before_host: false,
        },
      }),
    });

    const meeting = await response.json();

    if (!response.ok) {
      throw new Error(meeting.message || 'Failed to create Zoom meeting');
    }

    return res.status(200).json({
      success: true,
      meeting_id: meeting.id,
      join_url: meeting.join_url,
      start_time: meeting.start_time,
    });
  } catch (error) {
    console.error('[Zoom Error]', error);
    return res.status(500).json({ error: error.message });
  }
}
