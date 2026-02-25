export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();

  const { topic, start_time, duration } = req.body;

  try {
    // Step 1: Get Zoom token
    const tokenRes = await fetch('https://zoom.us/oauth/token', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${Buffer.from('fvNVWKX_SumngWI1kQNhg:zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g').toString('base64')}`,
      },
      body: 'grant_type=account_credentials&account_id=DXq-KNA5QuSpcjG6UeUs0Q',
    });

    const tokenData = await tokenRes.json();
    if (!tokenData.access_token) throw new Error('No token: ' + JSON.stringify(tokenData));

    // Step 2: Create meeting
    const meetRes = await fetch('https://api.zoom.us/v2/users/me/meetings', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${tokenData.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        topic,
        type: 2,
        start_time,
        duration,
        timezone: 'America/Sao_Paulo',
      }),
    });

    const meeting = await meetRes.json();
    res.json({ success: true, id: meeting.id, join_url: meeting.join_url });
  } catch (e) {
    res.status(500).json({ error: e.message, stack: e.stack });
  }
}
