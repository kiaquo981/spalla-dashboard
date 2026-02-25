export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { mentorado, mentorado_id, tipo, data, horario, duracao, email, notas } = req.body;

    // Create Zoom meeting if selected
    let zoom_meeting = null;
    if (req.body.use_zoom) {
      try {
        const zoomRes = await fetch(`${process.env.VERCEL_URL ? 'https://' + process.env.VERCEL_URL : 'http://localhost:3000'}/api/zoom-create-meeting`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            topic: `Mentoria ${tipo} - ${mentorado}`,
            start_time: `${data}T${horario}:00`,
            duration: duracao,
            email,
          }),
        });
        zoom_meeting = await zoomRes.json();
      } catch (e) {
        console.error('[Schedule] Zoom creation failed:', e.message);
        // Continue without Zoom - don't block scheduling
      }
    }

    return res.status(200).json({
      success: true,
      message: `Call scheduled for ${mentorado} on ${data} at ${horario}`,
      zoom: zoom_meeting?.success ? { meeting_id: zoom_meeting.meeting_id, join_url: zoom_meeting.join_url } : null,
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
