export default function handler(req, res) {
  console.log('[Health API] Handler called!');
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    message: 'API routing is working!',
  });
}
