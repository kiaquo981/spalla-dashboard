// Evolution API Direct HTTP Client
// Calls Evolution API directly from frontend (no proxy needed)

const EVOLUTION_BASE = 'https://evolution.manager01.feynmanproject.com';
const EVOLUTION_INSTANCE = 'produ02';
const EVOLUTION_API_KEY = '07826A779A5C-4E9C-A978-DBCD5F9E4C97';

class EvolutionDirect {
  constructor(baseUrl, instance, apiKey) {
    this.baseUrl = baseUrl;
    this.instance = instance;
    this.apiKey = apiKey;
  }

  // Get chats from Evolution API
  async getChats() {
    try {
      const url = `${this.baseUrl}/${this.instance}/chats`;
      console.log('[Evolution] Fetching chats from:', url);

      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Accept': 'application/json',
        },
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

  // Get messages from a chat
  async getMessages(remoteJid, limit = 50) {
    try {
      const url = `${this.baseUrl}/${this.instance}/messages/${encodeURIComponent(remoteJid)}`;
      console.log('[Evolution] Fetching messages from:', url);

      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Accept': 'application/json',
        },
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

  // Send message
  async sendMessage(remoteJid, text) {
    try {
      const url = `${this.baseUrl}/${this.instance}/message/sendText`;

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
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

// Initialize
const evolutionDirect = new EvolutionDirect(EVOLUTION_BASE, EVOLUTION_INSTANCE, EVOLUTION_API_KEY);

// Export
if (typeof module !== 'undefined' && module.exports) {
  module.exports = evolutionDirect;
}
