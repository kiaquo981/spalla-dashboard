export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();

  const { summary, start_time, duration, email } = req.body;

  if (!process.env.GOOGLE_SERVICE_ACCOUNT) {
    return res.status(500).json({ error: 'GOOGLE_SERVICE_ACCOUNT not set' });
  }

  try {
    const cred = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT);

    // Create JWT token manually
    const header = Buffer.from(JSON.stringify({ alg: 'RS256', typ: 'JWT' })).toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
    const now = Math.floor(Date.now() / 1000);
    const payload = Buffer.from(JSON.stringify({
      iss: cred.client_email,
      scope: 'https://www.googleapis.com/auth/calendar',
      aud: 'https://oauth2.googleapis.com/token',
      exp: now + 3600,
      iat: now,
    })).toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

    // Import crypto
    const { createSign } = await import('crypto');
    const sig = createSign('RSA-SHA256')
      .update(`${header}.${payload}`)
      .sign(cred.private_key, 'base64')
      .replace(/=/g, '')
      .replace(/\+/g, '-')
      .replace(/\//g, '_');

    const jwt = `${header}.${payload}.${sig}`;

    // Get token
    const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
    });

    const tokenData = await tokenRes.json();
    if (!tokenData.access_token) throw new Error('No token: ' + JSON.stringify(tokenData));

    // Create event
    const startDate = new Date(start_time);
    const endDate = new Date(startDate.getTime() + duration * 60000);

    const eventRes = await fetch('https://www.googleapis.com/calendar/v3/calendars/primary/events', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${tokenData.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        summary,
        start: { dateTime: startDate.toISOString(), timeZone: 'America/Sao_Paulo' },
        end: { dateTime: endDate.toISOString(), timeZone: 'America/Sao_Paulo' },
        attendees: email ? [{ email }] : [],
        conferenceData: {
          entryPoints: [{ entryPointType: 'video_conference' }],
          conferenceSolution: { key: { conferenceSolutionKey: { type: 'hangoutsMeet' } } },
        },
      }),
    });

    const event = await eventRes.json();
    res.json({ success: true, id: event.id, link: event.htmlLink });
  } catch (e) {
    res.status(500).json({ error: e.message, stack: e.stack });
  }
}
