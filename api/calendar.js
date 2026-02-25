async function getGoogleToken() {
  if (!process.env.GOOGLE_SERVICE_ACCOUNT) {
    throw new Error('GOOGLE_SERVICE_ACCOUNT not configured');
  }

  const cred = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT);
  const header = Buffer.from(JSON.stringify({
    alg: 'RS256',
    typ: 'JWT',
    kid: cred.private_key_id,
  })).toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

  const now = Math.floor(Date.now() / 1000);
  const payload = Buffer.from(JSON.stringify({
    iss: cred.client_email,
    scope: 'https://www.googleapis.com/auth/calendar',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  })).toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

  const crypto = await import('crypto');
  const sig = crypto.createSign('RSA-SHA256')
    .update(`${header}.${payload}`)
    .sign(cred.private_key, 'base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');

  const jwt = `${header}.${payload}.${sig}`;

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const data = await response.json();
  return data.access_token;
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') return res.status(200).end();

  try {
    const { summary, start_time, duration, email } = req.body;
    console.log('[Calendar] Creating event:', { summary, start_time, duration, email });
    const token = await getGoogleToken();
    console.log('[Calendar] Got token:', token.substring(0, 20) + '...');

    const startDate = new Date(start_time);
    const endDate = new Date(startDate.getTime() + duration * 60000);

    const response = await fetch('https://www.googleapis.com/calendar/v3/calendars/primary/events', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        summary,
        start: {
          dateTime: startDate.toISOString(),
          timeZone: 'America/Sao_Paulo',
        },
        end: {
          dateTime: endDate.toISOString(),
          timeZone: 'America/Sao_Paulo',
        },
        attendees: email ? [{ email }] : [],
        conferenceData: {
          entryPoints: [{ entryPointType: 'video_conference' }],
          conferenceSolution: { key: { conferenceSolutionKey: { type: 'hangoutsMeet' } } },
        },
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('[Calendar Error]', data);
      throw new Error(data.error?.message || 'Calendar API error');
    }

    res.json({ success: true, id: data.id, link: data.htmlLink });
  } catch (e) {
    console.error('[Calendar Exception]', e);
    res.status(500).json({ error: e.message });
  }
}
