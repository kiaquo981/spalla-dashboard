// Evolution API Client via Railway Backend Proxy
// Calls Railway backend which proxies to Evolution API (avoids CORS)

const BACKEND_URL = 'https://web-production-2cde5.up.railway.app';
const EVOLUTION_INSTANCE = 'produ02';

class EvolutionDirect {
  constructor(backendUrl, instance) {
    this.backendUrl = backendUrl;
    this.instance = instance;
  }

  // Get chats via Railway backend proxy
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
        console.warn('[Evolution] Failed to fetch chats:', response.status);
        return [];
      }

      const data = await response.json();
      console.log('[Evolution] Raw chats response:', data);

      // Handle different response formats
      const chatsArray = Array.isArray(data) ? data : (data.data || data.response || []);

      if (!Array.isArray(chatsArray)) {
        console.warn('[Evolution] Response is not an array:', chatsArray);
        return [];
      }

      // Convert to Spalla format
      return chatsArray.map(chat => ({
        id: chat.id || chat.key?.remoteJid,
        remoteJid: chat.id || chat.key?.remoteJid,
        name: chat.name || chat.pushName || 'Unknown',
        pushName: chat.pushName || chat.name,
        photo: chat.photo || null,
        isGroup: chat.isGroup || false,
        timestamp: chat.timestamp || Date.now(),
        updatedAt: new Date(chat.timestamp * 1000 || Date.now()).toISOString(),
        unreadCount: chat.unreadCount || 0,
      })).filter(c => c.id);
    } catch (error) {
      console.error('[Evolution] Error fetching chats:', error);
      return [];
    }
  }

  // Get messages via Railway backend proxy
  async getMessages(remoteJid, limit = 50) {
    try {
      const url = `${this.backendUrl}/api/wa`;
      console.log('[Evolution] Fetching messages via backend for:', remoteJid);

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
        console.warn('[Evolution] Failed to fetch messages:', response.status);
        return [];
      }

      const data = await response.json();
      const messagesArray = Array.isArray(data) ? data : (data.data || data.response || []);

      if (!Array.isArray(messagesArray)) {
        return [];
      }

      // Convert to Spalla format
      return messagesArray.map(msg => ({
        id: msg.key?.id || msg.id,
        fromMe: msg.key?.fromMe || false,
        sender: msg.key?.remoteJid || msg.sender,
        body: msg.message?.conversation || msg.message?.extendedTextMessage?.text || msg.body || '',
        timestamp: new Date(msg.messageTimestamp * 1000 || msg.timestamp).toISOString(),
        type: msg.message?.imageMessage ? 'image' : msg.message?.videoMessage ? 'video' : 'text',
      })).filter(m => m.body);
    } catch (error) {
      console.error('[Evolution] Error fetching messages:', error);
      return [];
    }
  }

  // Send message via Railway backend proxy
  async sendMessage(remoteJid, text) {
    try {
      const url = `${this.backendUrl}/api/wa`;

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
        throw new Error(`HTTP ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('[Evolution] Error sending message:', error);
      return null;
    }
  }
}

// Initialize with Railway backend
const evolutionDirect = new EvolutionDirect(BACKEND_URL, EVOLUTION_INSTANCE);

// Export
if (typeof module !== 'undefined' && module.exports) {
  module.exports = evolutionDirect;
}
