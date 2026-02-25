export default async function handler(req, res) {
  try {
    const tokenRes = await fetch('https://zoom.us/oauth/token', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${Buffer.from('fvNVWKX_SumngWI1kQNhg:zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g').toString('base64')}`,
      },
      body: 'grant_type=account_credentials&account_id=DXq-KNA5QuSpcjG6UeUs0Q',
    });

    const data = await tokenRes.json();
    res.json({
      status: tokenRes.status,
      ok: tokenRes.ok,
      response: data,
      hasToken: !!data.access_token,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}
