export default async function handler(req, res) {
  try {
    console.log('[Test Zoom] Testing account_credentials grant...');

    const tokenRes = await fetch('https://zoom.us/oauth/token', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${Buffer.from('fvNVWKX_SumngWI1kQNhg:zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g').toString('base64')}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=account_credentials&account_id=DXq-KNA5QuSpcjG6UeUs0Q',
    });

    const data = await tokenRes.json();

    // If failed, try client_credentials
    if (tokenRes.status === 400 && data.error === 'unsupported_grant_type') {
      console.log('[Test Zoom] account_credentials failed, trying client_credentials...');

      const tokenRes2 = await fetch('https://zoom.us/oauth/token', {
        method: 'POST',
        headers: {
          'Authorization': `Basic ${Buffer.from('fvNVWKX_SumngWI1kQNhg:zsgo0Xjtih8Yn2B0SLPVTK5J0Jh3WO9g').toString('base64')}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials&account_id=DXq-KNA5QuSpcjG6UeUs0Q',
      });

      const data2 = await tokenRes2.json();
      res.json({
        attempts: 2,
        attempt1_account_credentials: { status: tokenRes.status, response: data },
        attempt2_client_credentials: { status: tokenRes2.status, response: data2, hasToken: !!data2.access_token },
      });
      return;
    }

    res.json({
      attempts: 1,
      status: tokenRes.status,
      ok: tokenRes.ok,
      response: data,
      hasToken: !!data.access_token,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}
