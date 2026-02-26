// Evolution API Direct Integration
// Shared WhatsApp instance for all users

const EVOLUTION_BASE = 'https://evolution.manager01.feynmanproject.com';
const EVOLUTION_API_KEY = 'your_api_key_here'; // Will be set from config

class EvolutionClient {
  constructor(baseUrl, apiKey) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
  }

  // Get all instances (shared WhatsApp connections)
  async getInstances() {
    try {
      const response = await fetch(`${this.baseUrl}/instance/fetchInstances`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Accept': 'application/json',
        },
      });

      if (!response.ok) {
        console.warn('[Evolution] Failed to fetch instances:', response.status);
        return [];
      }

      const data = await response.json();
      return data.data || [];
    } catch (error) {
      console.error('[Evolution] Error fetching instances:', error);
      return [];
    }
  }

  // Get chats from a specific instance (SHARED for all users)
  async getChats(instanceName = 'produ02') {
    try {
      const response = await fetch(`${this.baseUrl}/${instanceName}/chats`, {
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
      const chats = data.response || data.data || [];

      // Convert to Spalla format
      return chats.map(chat => ({
        id: chat.id || chat.key?.remoteJid,
        remoteJid: chat.id || chat.key?.remoteJid,
        name: chat.name || chat.pushName || 'Unknown',
        pushName: chat.pushName || chat.name,
        photo: chat.photo || null,
        isGroup: chat.isGroup || false,
        isReadOnly: chat.isReadOnly || false,
        timestamp: chat.timestamp || Date.now(),
        updatedAt: new Date(chat.timestamp * 1000 || Date.now()).toISOString(),
        unreadCount: chat.unreadCount || 0,
      }));
    } catch (error) {
      console.error('[Evolution] Error fetching chats:', error);
      return [];
    }
  }

  // Get messages from a chat (SHARED for all users)
  async getMessages(instanceName = 'produ02', remoteJid) {
    try {
      const response = await fetch(`${this.baseUrl}/${instanceName}/messages/${remoteJid}`, {
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
      const messages = data.response || data.data || [];

      // Convert to Spalla format
      return messages.map(msg => ({
        id: msg.key?.id,
        fromMe: msg.key?.fromMe || false,
        sender: msg.key?.remoteJid,
        body: msg.message?.conversation || msg.message?.extendedTextMessage?.text || '',
        timestamp: new Date(msg.messageTimestamp * 1000).toISOString(),
        type: msg.message?.imageMessage ? 'image' : msg.message?.videoMessage ? 'video' : 'text',
        media: msg.message?.imageMessage?.url || msg.message?.videoMessage?.url || null,
      }));
    } catch (error) {
      console.error('[Evolution] Error fetching messages:', error);
      return [];
    }
  }

  // Send message (SHARED instance)
  async sendMessage(instanceName = 'produ02', remoteJid, message) {
    try {
      const response = await fetch(`${this.baseUrl}/${instanceName}/message/sendText`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          number: remoteJid,
          text: message,
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

// Initialize with placeholder (will be configured in app)
const evolutionClient = new EvolutionClient(EVOLUTION_BASE, EVOLUTION_API_KEY);

// Export for use in app
if (typeof module !== 'undefined' && module.exports) {
  module.exports = evolutionClient;
}
