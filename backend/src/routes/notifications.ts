// backend/src/routes/notifications.ts
// Sistema notifiche unificato: FCM push + in-app Firestore

import { Router } from 'express';
import { db, adminMessaging } from '../firebase';

const router = Router();

/**
 * Funzione riusabile: Invia notifica a utente
 * - Invia push notification via FCM
 * - Salva notifica in-app su Firestore
 * - Rimuove automaticamente token invalidi
 * 
 * @param userId - ID utente destinatario
 * @param payload - Contenuto notifica
 */
export async function sendNotificationToUser(
  userId: string,
  payload: {
    type?: string;
    title: string;
    body: string;
    data?: Record<string, string>;
  }
): Promise<void> {
  // 1. Recupera token FCM utente
  const tokenDoc = await db.collection('userPushTokens').doc(userId).get();

  if (!tokenDoc.exists) {
    console.log(`⚠️  No push tokens found for user: ${userId}`);
    // Continua comunque per salvare notifica in-app
  }

  const tokens = (tokenDoc.data()?.tokens as string[]) || [];

  // 2. Invia notifica push se ci sono token
  if (tokens.length > 0) {
    try {
      const response = await adminMessaging.sendMulticast({
        tokens,
        notification: {
          title: payload.title,
          body: payload.body
        },
        data: {
          ...(payload.data || {}),
          type: payload.type || 'generic'
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'default',
            sound: 'default'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      });

      console.log(
        `✅ Push notification sent to user ${userId}: ${response.successCount}/${tokens.length} successful`
      );

      // 3. Rimuovi token invalidi
      if (response.failureCount > 0) {
        const validTokens = tokens.filter(
          (token, index) => response.responses[index].success
        );

        await db.collection('userPushTokens').doc(userId).update({
          tokens: validTokens,
          updatedAt: new Date()
        });

        console.log(
          `🧹 Removed ${response.failureCount} invalid tokens for user ${userId}`
        );
      }
    } catch (err: any) {
      console.error('❌ FCM push notification error:', err.message);
      // Continua comunque per salvare notifica in-app
    }
  }

  // 4. Salva notifica in-app su Firestore
  await db
    .collection('notifications')
    .doc(userId)
    .collection('items')
    .add({
      type: payload.type || 'generic',
      title: payload.title,
      body: payload.body,
      data: payload.data || {},
      createdAt: new Date(),
      read: false
    });

  console.log(`✅ In-app notification saved for user ${userId}`);
}

/**
 * POST /api/notifications/test
 * Endpoint di test notifiche (rimuovere in produzione)
 */
router.post('/test', async (req, res) => {
  try {
    const { userId, title, body } = req.body;

    if (!userId || !title || !body) {
      return res.status(400).json({ error: 'Missing params: userId, title, body' });
    }

    await sendNotificationToUser(userId, {
      type: 'test',
      title,
      body
    });

    return res.json({ ok: true, message: 'Test notification sent' });
  } catch (err: any) {
    console.error('❌ Notification test error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * POST /api/notifications/register-token
 * Registra token FCM per utente
 * 
 * Body:
 * - userId: string
 * - token: string (FCM device token)
 */
router.post('/register-token', async (req, res) => {
  try {
    const { userId, token } = req.body;

    if (!userId || !token) {
      return res.status(400).json({ error: 'Missing params: userId, token' });
    }

    // Aggiungi token all'array (evita duplicati con arrayUnion)
    await db
      .collection('userPushTokens')
      .doc(userId)
      .set(
        {
          tokens: admin.firestore.FieldValue.arrayUnion(token),
          updatedAt: new Date()
        },
        { merge: true }
      );

    console.log(`✅ FCM token registered for user ${userId}`);

    return res.json({ ok: true, message: 'Token registered' });
  } catch (err: any) {
    console.error('❌ Register token error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * GET /api/notifications/:userId
 * Lista notifiche in-app per utente
 * 
 * Query params:
 * - limit?: number (default: 50)
 * - unreadOnly?: boolean (default: false)
 */
router.get('/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const limit = parseInt(req.query.limit as string) || 50;
    const unreadOnly = req.query.unreadOnly === 'true';

    let query = db
      .collection('notifications')
      .doc(userId)
      .collection('items')
      .orderBy('createdAt', 'desc')
      .limit(limit);

    if (unreadOnly) {
      query = query.where('read', '==', false) as any;
    }

    const snapshot = await query.get();

    const notifications = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data()
    }));

    return res.json(notifications);
  } catch (err: any) {
    console.error('❌ Get notifications error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * POST /api/notifications/:userId/:notificationId/mark-read
 * Marca notifica come letta
 */
router.post('/:userId/:notificationId/mark-read', async (req, res) => {
  try {
    const { userId, notificationId } = req.params;

    await db
      .collection('notifications')
      .doc(userId)
      .collection('items')
      .doc(notificationId)
      .update({
        read: true,
        readAt: new Date()
      });

    console.log(`✅ Notification ${notificationId} marked as read for user ${userId}`);

    return res.json({ ok: true, message: 'Notification marked as read' });
  } catch (err: any) {
    console.error('❌ Mark read error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
