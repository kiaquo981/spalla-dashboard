export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { mentorado, mentorado_id, tipo, data, horario, duracao, email, notas } = req.body;
    console.log('[Schedule] Request:', { mentorado, tipo, data, horario, duracao, email });

    // Data can be either dd/mm/yyyy or yyyy-mm-dd format
    let isoDate;
    if (data.includes('/')) {
      const [dia, mes, ano] = data.split('/');
      isoDate = `${ano}-${mes}-${dia}`;
    } else {
      isoDate = data; // Already in yyyy-mm-dd format
    }
    const startTime = `${isoDate}T${horario}:00`;
    console.log('[Schedule] Parsed date:', { input: data, isoDate, startTime });

    let zoomResult = null, calendarResult = null;
    let zoomError = null, calendarError = null;

    // ============ ZOOM INLINE ============
    try {
      console.log('[Schedule] Creating Zoom meeting...');

      // Step 1: Get Zoom token
      const tokenRes = await fetch('https://zoom.us/oauth/token', {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${Buffer.from('fvNVWKX_SumngWI1kQNhg:zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g').toString('base64')}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=account_credentials&account_id=DXq-KNA5QuSpcjG6UeUs0Q',
      });

      const tokenData = await tokenRes.json();
      console.log('[Schedule] Zoom token:', { status: tokenRes.status, ok: tokenRes.ok, hasToken: !!tokenData.access_token });

      if (!tokenData.access_token) {
        throw new Error(`No Zoom token: ${JSON.stringify(tokenData)}`);
      }

      // Step 2: Create meeting
      const meetRes = await fetch('https://api.zoom.us/v2/users/me/meetings', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${tokenData.access_token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          topic: `Mentoria ${tipo} - ${mentorado}`,
          type: 2,
          start_time: startTime,
          duration: duracao,
          timezone: 'America/Sao_Paulo',
        }),
      });

      const meeting = await meetRes.json();
      console.log('[Schedule] Zoom meeting:', { status: meetRes.status, id: meeting.id });

      if (meeting.id) {
        zoomResult = { success: true, id: meeting.id, join_url: meeting.join_url };
      } else {
        throw new Error(`No meeting ID: ${JSON.stringify(meeting)}`);
      }
    } catch (e) {
      zoomError = e.message;
      console.error('[Schedule] Zoom error:', e.message);
    }

    // ============ GOOGLE CALENDAR INLINE ============
    try {
      console.log('[Schedule] Creating Google Calendar event...');

      if (!process.env.GOOGLE_SERVICE_ACCOUNT) {
        throw new Error('GOOGLE_SERVICE_ACCOUNT not configured');
      }

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
      console.log('[Schedule] JWT created');

      // Get token
      const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
      });

      const tokenData = await tokenRes.json();
      console.log('[Schedule] Calendar token:', { status: tokenRes.status, ok: tokenRes.ok, hasToken: !!tokenData.access_token });

      if (!tokenData.access_token) {
        throw new Error('No Calendar token: ' + JSON.stringify(tokenData));
      }

      // Create event
      const startDate = new Date(startTime);
      const endDate = new Date(startDate.getTime() + duracao * 60000);

      console.log('[Schedule] Creating Calendar event:', { summary: `Mentoria ${tipo} - ${mentorado}`, startDate, endDate });

      const eventRes = await fetch('https://www.googleapis.com/calendar/v3/calendars/primary/events?conferenceDataVersion=1', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${tokenData.access_token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          summary: `Mentoria ${tipo} - ${mentorado}`,
          start: { dateTime: startDate.toISOString(), timeZone: 'America/Sao_Paulo' },
          end: { dateTime: endDate.toISOString(), timeZone: 'America/Sao_Paulo' },
          description: email ? `Participante: ${email}` : '',
          conferenceData: {
            createRequest: {
              requestId: `meet-${Date.now()}`,
              conferenceSolution: { key: { conferenceSolutionKey: 'hangoutsMeet' } },
            },
          },
        }),
      });

      const event = await eventRes.json();
      console.log('[Schedule] Calendar event:', { status: eventRes.status, id: event.id, link: event.htmlLink });

      if (event.id) {
        calendarResult = { success: true, id: event.id, link: event.htmlLink };
      } else {
        throw new Error(`No event ID: ${JSON.stringify(event)}`);
      }
    } catch (e) {
      calendarError = e.message;
      console.error('[Schedule] Calendar error:', e.message);
    }

    // Save to Supabase
    const data_call = `${isoDate}T${horario}:00`;
    try {
      const sbRes = await fetch('https://knusqfbvhsqworzyhvip.supabase.co/rest/v1/calls_mentoria', {
        method: 'POST',
        headers: {
          'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtudXNxZmJ2aHNxd29yenlodmlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4NTg3MjcsImV4cCI6MjA3MDQzNDcyN30.f-m7TlmCoccBpUxLZhA4P5kr2lWBGtRIv6inzInAKCo',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          mentorado_id,
          data_call,
          tipo,
          status: 'agendada',
          zoom_meeting_id: zoomResult?.id || null,
          zoom_join_url: zoomResult?.join_url || null,
          calendar_event_id: calendarResult?.id || null,
          calendar_event_link: calendarResult?.link || null,
        }),
      });
      console.log('[Schedule] Supabase save:', sbRes.status);
    } catch (e) {
      console.error('[Schedule] Supabase save error:', e.message);
    }

    return res.status(200).json({
      success: true,
      message: `✅ Call scheduled for ${mentorado}`,
      zoom: zoomResult,
      zoomError,
      calendar: calendarResult,
      calendarError,
      scheduled: { mentorado_id, tipo, data: isoDate, horario, duracao, email, notas },
    });
  } catch (error) {
    console.error('[Schedule] Fatal error:', error.message);
    return res.status(500).json({ error: error.message });
  }
}
