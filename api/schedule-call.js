export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { mentorado, mentorado_id, tipo, data, horario, duracao, email, notas } = req.body;

    // On Vercel, we just return success without creating actual meeting
    // Full integration only works with local Python server
    return res.status(200).json({
      success: true,
      message: `Call scheduled for ${mentorado} on ${data} at ${horario}`,
      note: 'Note: Full Zoom/Calendar integration only available on local server',
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
