import { google } from 'googleapis';

const SERVICE_ACCOUNT = process.env.GOOGLE_SERVICE_ACCOUNT
  ? JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT)
  : null;

const CALENDAR_ID = 'primary';

async function getCalendarClient() {
  if (!SERVICE_ACCOUNT) {
    throw new Error('Google Service Account not configured');
  }

  const auth = new google.auth.GoogleAuth({
    credentials: SERVICE_ACCOUNT,
    scopes: ['https://www.googleapis.com/auth/calendar'],
  });

  return google.calendar({ version: 'v3', auth });
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { summary, description, start_time, duration, attendee_email } = req.body;
    const calendar = await getCalendarClient();

    const startDate = new Date(start_time);
    const endDate = new Date(startDate.getTime() + duration * 60000);

    const event = {
      summary,
      description,
      start: {
        dateTime: startDate.toISOString(),
        timeZone: 'America/Sao_Paulo',
      },
      end: {
        dateTime: endDate.toISOString(),
        timeZone: 'America/Sao_Paulo',
      },
      attendees: attendee_email ? [{ email: attendee_email }] : [],
      conferenceData: {
        entryPoints: [
          {
            entryPointType: 'video_conference',
            label: 'Google Meet',
          },
        ],
        conferenceSolution: {
          key: { conferenceSolutionKey: { type: 'hangoutsMeet' } },
        },
      },
    };

    const response = await calendar.events.insert({
      calendarId: CALENDAR_ID,
      resource: event,
      conferenceDataVersion: 1,
    });

    return res.status(200).json({
      success: true,
      event_id: response.data.id,
      event_link: response.data.htmlLink,
      meet_link: response.data.conferenceData?.entryPoints?.[0]?.uri || null,
    });
  } catch (error) {
    console.error('[Calendar Error]', error);
    return res.status(500).json({ error: error.message });
  }
}
