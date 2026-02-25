export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { mentorado, mentorado_id, tipo, data, horario, duracao, email, notas } = req.body;

    // Data comes as dd/mm/yyyy, convert to ISO format (yyyy-mm-dd)
    const [dia, mes, ano] = data.split('/');
    const isoDate = `${ano}-${mes}-${dia}`;

    return res.status(200).json({
      success: true,
      message: `✅ Call scheduled for ${mentorado} on ${data} at ${horario}`,
      note: 'For full Zoom + Google Calendar integration, use local Python server with: python3 14-APP-server.py 8888',
      scheduled: {
        mentorado_id,
        tipo,
        data: isoDate,
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
