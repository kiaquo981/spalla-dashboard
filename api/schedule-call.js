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
    const baseUrl = process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : 'http://localhost:3000';

    let zoomResult = null, calendarResult = null;

    // Zoom
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
      const zData = await zRes.text();
      console.log('[Schedule] Zoom status:', zRes.status, 'body:', zData);
      if (zRes.ok) zoomResult = JSON.parse(zData);
    } catch (e) {
      console.error('[Schedule] Zoom error:', e);
    }

    // Calendar
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
      const cData = await cRes.text();
      console.log('[Schedule] Calendar status:', cRes.status, 'body:', cData);
      if (cRes.ok) calendarResult = JSON.parse(cData);
    } catch (e) {
      console.error('[Schedule] Calendar error:', e);
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
