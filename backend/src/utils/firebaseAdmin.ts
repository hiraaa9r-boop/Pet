/**
 * Firebase Admin SDK Singleton
 * Single initialization point for Firebase Admin SDK
 */

import { readFileSync } from 'fs';

import * as admin from 'firebase-admin';

let app: admin.app.App | null = null;

/**
 * Get or initialize Firebase Admin App
 * Handles both Cloud Run (automatic) and local (with service account) environments
 */
export function getAdminApp(): admin.app.App {
  if (!app) {
    if (admin.apps.length) {
      app = admin.app();
    } else {
      const isCloudRun = process.env.K_SERVICE !== undefined;

      if (isCloudRun) {
        // Cloud Run: automatic authentication via service account
        console.log('🔥 Firebase Admin: Initializing with Cloud Run service account');
        app = admin.initializeApp({
          storageBucket:
            process.env.FIREBASE_STORAGE_BUCKET || 'pet-care-9790d.appspot.com',
        });
      } else {
        // Local development: use service account key file
        const keyPath =
          process.env.GOOGLE_APPLICATION_CREDENTIALS || './keys/firebase-key.json';
        console.log(`🔥 Firebase Admin: Initializing with key file: ${keyPath}`);

        try {
          const serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));
          app = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            storageBucket:
              process.env.FIREBASE_STORAGE_BUCKET ||
              serviceAccount.project_id + '.appspot.com',
          });
        } catch (error: any) {
          console.error('❌ Failed to initialize Firebase Admin SDK:');
          console.error(
            '   Make sure GOOGLE_APPLICATION_CREDENTIALS points to a valid service account key file',
          );
          console.error('   Error:', error.message);
          process.exit(1);
        }
      }

      console.log('✅ Firebase Admin SDK initialized successfully');
    }
  }

  return app;
}

/**
 * Get Firestore instance
 */
export function getDb(): admin.firestore.Firestore {
  return getAdminApp().firestore();
}

/**
 * Get Firebase Auth instance
 */
export function getAuth(): admin.auth.Auth {
  return getAdminApp().auth();
}

/**
 * Get Firebase Storage bucket
 */
export function getBucket(): admin.storage.Storage {
  return getAdminApp().storage();
}
