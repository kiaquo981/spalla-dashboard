export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();

  const { topic, start_time, duration } = req.body;

  try {
    // Step 1: Get Zoom token - try multiple approaches
    let tokenRes = null;
    let tokenData = null;

    console.log('[Zoom] Attempting token fetch...');

    // Attempt 1: Original account_credentials approach with Content-Type
    tokenRes = await fetch('https://zoom.us/oauth/token', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${Buffer.from('fvNVWKX_SumngWI1kQNhg:zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g').toString('base64')}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=account_credentials&account_id=DXq-KNA5QuSpcjG6UeUs0Q',
    });

    tokenData = await tokenRes.json();
    console.log('[Zoom] Token response:', { status: tokenRes.status, ok: tokenRes.ok, data: tokenData });

    // If account_credentials fails, try client_credentials (standard OAuth 2.0)
    if (!tokenData.access_token && tokenRes.status === 400) {
      console.log('[Zoom] account_credentials failed, trying client_credentials...');
      tokenRes = await fetch('https://zoom.us/oauth/token', {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${Buffer.from('fvNVWKX_SumngWI1kQNhg:zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g').toString('base64')}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials&account_id=DXq-KNA5QuSpcjG6UeUs0Q',
      });
      tokenData = await tokenRes.json();
      console.log('[Zoom] client_credentials response:', { status: tokenRes.status, ok: tokenRes.ok, data: tokenData });
    }

    if (!tokenData.access_token) {
      throw new Error(`Token failed: ${tokenRes.status} - ${JSON.stringify(tokenData)}`);
    }

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
    console.log('[Zoom] Meeting created:', { status: meetRes.status, id: meeting.id });
    res.json({ success: true, id: meeting.id, join_url: meeting.join_url });
  } catch (e) {
    console.error('[Zoom] Error:', e.message);
    res.status(500).json({ error: e.message, stack: e.stack });
  }
}
