// Evolution API Client via Railway Backend Proxy
// Calls Railway backend which proxies to Evolution API (avoids CORS)
// **Fixed: Now uses correct Evolution API endpoints via backend**

const BACKEND_URL = window.location.hostname === 'localhost'
  ? 'http://localhost:8000'
  : 'https://web-production-2cde5.up.railway.app';

const EVOLUTION_INSTANCE = 'produ02';

console.log('[Evolution] Initializing with backend URL:', BACKEND_URL);

class EvolutionDirect {
  constructor(backendUrl, instance) {
    this.backendUrl = backendUrl;
    this.instance = instance;
  }

  // Get chats via Railway backend proxy (calls Evolution API POST /chat/findChats/produ02)
  async getChats() {
    try {
      const url = `${this.backendUrl}/api/wa`;
      console.log('[Evolution] Fetching chats via backend:', url);

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: 'findChats',
        }),
      });

      if (!response.ok) {
        console.warn('[Evolution] Failed to fetch chats:', response.status, response.statusText);
        const errorData = await response.json().catch(() => ({}));
        console.error('[Evolution] Error details:', errorData);
        return [];
      }

      const data = await response.json();
      console.log('[Evolution] Raw chats response - count:', Array.isArray(data) ? data.length : 'not array');

      // Handle different response formats (Evolution returns array)
      const chatsArray = Array.isArray(data) ? data : (data.data || data.response || []);

      if (!Array.isArray(chatsArray)) {
        console.warn('[Evolution] Response is not an array:', typeof chatsArray);
        return [];
      }

      // Convert Evolution format to Spalla format
      return chatsArray.map(chat => ({
        id: chat.id,
        remoteJid: chat.remoteJid,
        name: chat.pushName || 'Unknown Chat',
        pushName: chat.pushName || '',
        profilePicUrl: chat.profilePicUrl || null,
        updatedAt: chat.updatedAt || new Date().toISOString(),
        unreadCount: chat.unreadCount || 0,
        isGroup: chat.remoteJid?.includes('@g.us') || false,
      })).filter(c => c.id && c.remoteJid);
    } catch (error) {
      console.error('[Evolution] Error fetching chats:', error);
      return [];
    }
  }

  // Get messages via Railway backend proxy (calls Evolution API POST /chat/findMessages/produ02)
  async getMessages(remoteJid, limit = 50) {
    try {
      const url = `${this.backendUrl}/api/wa`;
      console.log('[Evolution] Fetching messages for:', remoteJid, `(limit: ${limit})`);

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: 'findMessages',
          remoteJid: remoteJid,
          limit: limit,
        }),
      });

      if (!response.ok) {
        console.warn('[Evolution] Failed to fetch messages:', response.status, response.statusText);
        const errorData = await response.json().catch(() => ({}));
        console.error('[Evolution] Error details:', errorData);
        return [];
      }

      const data = await response.json();
      console.log('[Evolution] Fetched messages - count:', Array.isArray(data) ? data.length : 'not array');

      // Handle different response formats (Evolution returns array or object with messages)
      let messagesArray = [];
      if (Array.isArray(data)) {
        messagesArray = data;
      } else if (data.messages && Array.isArray(data.messages)) {
        messagesArray = data.messages;
      } else if (data.messages?.records && Array.isArray(data.messages.records)) {
        messagesArray = data.messages.records;
      }

      if (!Array.isArray(messagesArray)) {
        console.warn('[Evolution] Messages is not an array');
        return [];
      }

      // Convert Evolution format to Spalla format
      return messagesArray.map(msg => ({
        id: msg.id,
        fromMe: msg.key?.fromMe || false,
        sender: msg.key?.remoteJid || msg.sender || remoteJid,
        senderName: msg.pushName || '',
        body: msg.message?.conversation || msg.message?.extendedTextMessage?.text || msg.body || '',
        timestamp: new Date((msg.messageTimestamp || msg.timestamp) * 1000 || Date.now()).toISOString(),
        type: this._getMessageType(msg),
        media: this._extractMediaUrl(msg),
      })).filter(m => m.body);
    } catch (error) {
      console.error('[Evolution] Error fetching messages:', error);
      return [];
    }
  }

  // Send message via Railway backend proxy (calls Evolution API POST /message/sendText/produ02)
  async sendMessage(remoteJid, text) {
    try {
      const url = `${this.backendUrl}/api/wa`;
      console.log('[Evolution] Sending message to:', remoteJid);

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: 'sendText',
          number: remoteJid,
          text: text,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(`HTTP ${response.status}: ${JSON.stringify(errorData)}`);
      }

      const result = await response.json();
      console.log('[Evolution] Message sent successfully');
      return result;
    } catch (error) {
      console.error('[Evolution] Error sending message:', error);
      throw error; // Re-throw so caller can handle
    }
  }

  // Helper: Determine message type
  _getMessageType(msg) {
    const message = msg.message || {};
    if (message.imageMessage) return 'image';
    if (message.videoMessage) return 'video';
    if (message.audioMessage) return 'audio';
    if (message.documentMessage) return 'document';
    if (message.stickerMessage) return 'sticker';
    return 'text';
  }

  // Helper: Extract media URL
  _extractMediaUrl(msg) {
    const message = msg.message || {};
    if (message.imageMessage?.url) return message.imageMessage.url;
    if (message.videoMessage?.url) return message.videoMessage.url;
    if (message.audioMessage?.url) return message.audioMessage.url;
    if (message.documentMessage?.url) return message.documentMessage.url;
    return null;
  }
}

// Initialize with Railway backend
const evolutionDirect = new EvolutionDirect(BACKEND_URL, EVOLUTION_INSTANCE);

console.log('[Evolution] Client initialized. Backend:', BACKEND_URL);

// Export
if (typeof module !== 'undefined' && module.exports) {
  module.exports = evolutionDirect;
}

// Also export the class for testing/debugging
if (typeof window !== 'undefined') {
  window.EvolutionDirect = EvolutionDirect;
  window.evolutionDirect = evolutionDirect;
}
