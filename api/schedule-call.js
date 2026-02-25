export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { mentorado, mentorado_id, tipo, data, horario, duracao, email, notas } = req.body;

    const baseUrl = process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : 'http://localhost:3000';
    const startTime = `${data}T${horario}:00`;

    // Create Zoom meeting
    let zoom_meeting = null;
    try {
      const zoomRes = await fetch(`${baseUrl}/api/zoom-create-meeting`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          topic: `Mentoria ${tipo} - ${mentorado}`,
          start_time: startTime,
          duration: duracao,
          email,
        }),
      });
      zoom_meeting = await zoomRes.json();
    } catch (e) {
      console.error('[Schedule] Zoom creation failed:', e.message);
    }

    // Create Google Calendar event
    let calendar_event = null;
    try {
      const calRes = await fetch(`${baseUrl}/api/calendar-create-event`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          summary: `Mentoria ${tipo} - ${mentorado}`,
          description: notas || `Call de ${tipo}`,
          start_time: startTime,
          duration: duracao,
          attendee_email: email,
        }),
      });
      calendar_event = await calRes.json();
    } catch (e) {
      console.error('[Schedule] Calendar creation failed:', e.message);
    }

    return res.status(200).json({
      success: true,
      message: `Call scheduled for ${mentorado} on ${data} at ${horario}`,
      zoom: zoom_meeting?.success ? { meeting_id: zoom_meeting.meeting_id, join_url: zoom_meeting.join_url } : null,
      calendar: calendar_event?.success ? { event_id: calendar_event.event_id, event_link: calendar_event.event_link, meet_link: calendar_event.meet_link } : null,
      scheduled: {
        mentorado_id,
        tipo,
        data,
        horario,
        duracao,
        email,
        notas,
      },
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
}
