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
    let isoDate, dataFormatada;
    if (data.includes('/')) {
      const [dia, mes, ano] = data.split('/');
      isoDate = `${ano}-${mes}-${dia}`;
      dataFormatada = data; // Keep as dd/mm/yyyy
    } else {
      isoDate = data; // Already in yyyy-mm-dd format
      const [ano, mes, dia] = data.split('-');
      dataFormatada = `${dia}/${mes}/${ano}`; // Convert to dd/mm/yyyy
    }
    const startTime = `${isoDate}T${horario}:00`;
    console.log('[Schedule] Parsed date:', { input: data, isoDate, startTime });

    // Format event title: [Case] Nome - Tipo de Reunião - Data
    const tiposReuniao = {
      'acompanhamento': 'Reunião de Acompanhamento',
      'onboarding': 'Reunião de Onboarding',
      'diagnóstico': 'Reunião de Diagnóstico',
      'diagnostico': 'Reunião de Diagnóstico',
      'planejamento': 'Reunião de Planejamento',
      'consulta': 'Consulta',
      'mentoria': 'Mentoria',
    };
    const tipoReuniao = tiposReuniao[tipo?.toLowerCase()] || `Reunião de ${tipo}`;
    const eventTitle = `[Case] ${mentorado} - ${tipoReuniao} - ${dataFormatada}`;

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
          topic: eventTitle,
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

      // Build description with all details
      const descriptionLines = [
        `=== DETALHES DA REUNIÃO ===`,
        `Horário: ${horario}`,
        `Duração: ${duracao} minutos`,
        `Data: ${dataFormatada}`,
        ``,
        `=== PARTICIPANTES ===`,
        email ? `Mentorado: ${mentorado} (${email})` : `Mentorado: ${mentorado}`,
        `Coordenador: Queila Trizotti (queila.trizotti@gmail.com)`,
        `Admin: adm@allindigitalmarketing.com.br`,
        ``,
        `=== LINK ZOOM ===`,
        `${zoomResult?.join_url || 'Link do Zoom será adicionado após criação'}`,
        ``,
        notas ? `=== NOTAS ===\n${notas}` : ''
      ].filter(line => line !== '').join('\n');

      console.log('[Schedule] Creating Calendar event:', { summary: eventTitle, startDate: startDate.toISOString(), endDate: endDate.toISOString(), attendees: [email, 'queila.trizotti@gmail.com', 'adm@allindigitalmarketing.com.br'] });

      // Build attendees list
      const attendees = [];
      if (email) attendees.push({ email, responseStatus: 'needsAction' });
      attendees.push({ email: 'queila.trizotti@gmail.com', responseStatus: 'needsAction' });
      attendees.push({ email: 'adm@allindigitalmarketing.com.br', responseStatus: 'needsAction', organizer: true });

      const eventRes = await fetch('https://www.googleapis.com/calendar/v3/calendars/primary/events?conferenceDataVersion=1&supportsAttachments=true', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${tokenData.access_token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          summary: eventTitle,
          start: { dateTime: startDate.toISOString(), timeZone: 'America/Sao_Paulo' },
          end: { dateTime: endDate.toISOString(), timeZone: 'America/Sao_Paulo' },
          description: descriptionLines,
          attendees: attendees,
          conferenceData: {
            createRequest: {
              requestId: `meet-${Date.now()}`,
              conferenceSolution: { key: { conferenceSolutionKey: 'hangoutsMeet' } },
            },
          },
        }),
      });

      let event = await eventRes.json();
      console.log('[Schedule] Calendar response:', { status: eventRes.status, ok: eventRes.ok, hasId: !!event.id });

      // If first attempt failed with attendees, try without
      if (!eventRes.ok && eventRes.status === 403 && event.error?.message?.includes('Domain-Wide Delegation')) {
        console.log('[Schedule] Domain-Wide Delegation error, retrying without attendees...');

        const eventRes2 = await fetch('https://www.googleapis.com/calendar/v3/calendars/primary/events?conferenceDataVersion=1', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${tokenData.access_token}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            summary: eventTitle,
            start: { dateTime: startDate.toISOString(), timeZone: 'America/Sao_Paulo' },
            end: { dateTime: endDate.toISOString(), timeZone: 'America/Sao_Paulo' },
            description: descriptionLines + '\n\n⚠️  Attendees need to be invited manually (service account limitation)',
            conferenceData: {
              createRequest: {
                requestId: `meet-${Date.now()}`,
                conferenceSolution: { key: { conferenceSolutionKey: 'hangoutsMeet' } },
              },
            },
          }),
        });

        event = await eventRes2.json();
        console.log('[Schedule] Retry response:', { status: eventRes2.status, ok: eventRes2.ok, hasId: !!event.id });

        if (!event.id) {
          throw new Error(`Calendar creation failed even without attendees: ${JSON.stringify(event)}`);
        }
      } else if (!eventRes.ok) {
        throw new Error(`Calendar API error ${eventRes.status}: ${JSON.stringify(event)}`);
      }

      if (event.id) {
        calendarResult = { success: true, id: event.id, link: event.htmlLink };
        console.log('[Schedule] Calendar event created:', { id: event.id, link: event.htmlLink });
      } else {
        throw new Error(`No event ID in response: ${JSON.stringify(event)}`);
      }
    } catch (e) {
      calendarError = e.message;
      console.error('[Schedule] Calendar error:', e.message, e.stack);
    }

    // Save to Supabase with São Paulo timezone offset (-03:00)
    const data_call = `${isoDate}T${horario}:00-03:00`;
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
