export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { mentorado, mentorado_id, tipo, data, horario, duracao, email, notas } = req.body;
    console.log('[Schedule] Request:', { mentorado, tipo, data, horario, duracao, email });

    const [dia, mes, ano] = data.split('/');
    const isoDate = `${ano}-${mes}-${dia}`;
    const startTime = `${isoDate}T${horario}:00`;
    const baseUrl = process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : 'http://localhost:3000';

    let zoomResult = null, calendarResult = null;

    try {
      const zRes = await fetch(`${baseUrl}/api/zoom`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          topic: `Mentoria ${tipo} - ${mentorado}`,
          start_time: startTime,
          duration: duracao,
        }),
      });
      zoomResult = await zRes.json();
    } catch (e) {
      console.error('[Schedule] Zoom failed:', e.message);
    }

    try {
      const cRes = await fetch(`${baseUrl}/api/calendar`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          summary: `Mentoria ${tipo} - ${mentorado}`,
          start_time: startTime,
          duration: duracao,
          email,
        }),
      });
      calendarResult = await cRes.json();
    } catch (e) {
      console.error('[Schedule] Calendar failed:', e.message);
    }

    return res.status(200).json({
      success: true,
      message: `✅ Call scheduled for ${mentorado}`,
      zoom: zoomResult?.success ? zoomResult : null,
      calendar: calendarResult?.success ? calendarResult : null,
      scheduled: { mentorado_id, tipo, data: isoDate, horario, duracao, email, notas },
    });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
}
