// ===== ENVIRONMENT CONFIG =====
// Set API_BASE_URL from environment or query param
window.API_BASE_URL = (typeof process !== 'undefined' && process.env?.API_BASE_URL) ||
                      new URLSearchParams(window.location.search).get('api_base') ||
                      '';  // empty string = same origin (localhost or same domain)

// Log for debugging
if (window.API_BASE_URL) {
  console.log('[Config] API Base URL:', window.API_BASE_URL);
}
