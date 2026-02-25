export default async function handler(req, res) {
  if (!process.env.GOOGLE_SERVICE_ACCOUNT) {
    return res.json({ error: 'GOOGLE_SERVICE_ACCOUNT not configured' });
  }

  try {
    const cred = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT);
    res.json({
      hasServiceAccount: true,
      email: cred.client_email,
      hasPrivateKey: !!cred.private_key,
      projectId: cred.project_id,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
}
