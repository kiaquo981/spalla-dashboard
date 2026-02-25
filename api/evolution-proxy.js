/**
 * SPALLA Evolution API Proxy
 * Serverless function to forward Evolution API requests from frontend
 * Replaces the Python server's _proxy_evolution() function on Vercel
 */

const EVOLUTION_BASE = 'https://evolution.manager01.feynmanproject.com';
const EVOLUTION_API_KEY = '07826A779A5C-4E9C-A978-DBCD5F9E4C97';

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token,X-Requested-With,Accept,Accept-Version,Content-Length,Content-MD5,Content-Type,Date,X-Api-Version');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    // Extract the Evolution API path (everything after /api/evolution)
    const evolutionPath = req.url.replace('/api/evolution-proxy', '');
    const targetUrl = `${EVOLUTION_BASE}${evolutionPath}`;

    console.log(`[Evolution Proxy] ${req.method} ${targetUrl}`);

    // Build fetch options
    const fetchOptions = {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        'apikey': EVOLUTION_API_KEY,
      },
    };

    // Add body for POST requests
    if (req.method === 'POST' && req.body) {
      fetchOptions.body = JSON.stringify(req.body);
    }

    // Make request to Evolution API
    const response = await fetch(targetUrl, fetchOptions);
    const data = await response.json();

    // Return response
    if (response.ok) {
      res.status(200).json(data);
    } else {
      console.error(`[Evolution Proxy] Error:`, response.status, data);
      res.status(response.status).json({ error: data?.message || 'Evolution API error' });
    }
  } catch (error) {
    console.error('[Evolution Proxy] Exception:', error);
    res.status(500).json({ error: error.message });
  }
}
