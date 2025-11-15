// backend/src/auth/setAdmin.ts
/**
 * Script per impostare custom claims admin su Firebase Auth
 * 
 * Uso:
 * 1. Modifica l'UID dell'utente da promuovere
 * 2. Esegui: npx ts-node src/auth/setAdmin.ts
 * 3. L'utente deve fare logout/login per ricaricare i claims
 */

import * as admin from 'firebase-admin';

// Inizializza Firebase Admin (se non già fatto)
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Imposta o rimuove il ruolo admin per un utente
 * @param uid - UID dell'utente Firebase Auth
 * @param isAdmin - true per promuovere, false per rimuovere
 */
async function setAdmin(uid: string, isAdmin: boolean) {
  try {
    const user = await admin.auth().getUser(uid);
    console.log(`📋 Utente trovato: ${user.email}`);

    // Ottieni i claims esistenti
    const currentClaims = user.customClaims || {};
    
    // Imposta il claim admin
    currentClaims.admin = isAdmin;

    // Applica i custom claims
    await admin.auth().setCustomUserClaims(uid, currentClaims);
    
    console.log(`✅ Utente ${uid} ora ha admin=${isAdmin}`);
    console.log(`📧 Email: ${user.email}`);
    console.log(`⚠️  L'utente deve fare logout/login per ricaricare i claims`);
    
    // Verifica i claims applicati
    const updatedUser = await admin.auth().getUser(uid);
    console.log(`🔍 Claims verificati:`, updatedUser.customClaims);
    
  } catch (error) {
    console.error('❌ Errore durante l\'impostazione admin:', error);
    throw error;
  }
}

// ========================================
// CONFIGURAZIONE: Modifica qui il tuo UID
// ========================================

const UID_DA_PROMUOVERE = 'INSERISCI_QUI_UID_UTENTE';
const SET_AS_ADMIN = true; // true = promuovi, false = rimuovi

// ========================================

async function main() {
  if (UID_DA_PROMUOVERE === 'INSERISCI_QUI_UID_UTENTE') {
    console.error('❌ ERRORE: Devi modificare UID_DA_PROMUOVERE nello script!');
    console.log('\n📝 Come trovare l\'UID:');
    console.log('1. Firebase Console → Authentication → Users');
    console.log('2. Copia l\'UID dell\'utente desiderato');
    console.log('3. Incolla in questo file nella variabile UID_DA_PROMUOVERE\n');
    process.exit(1);
  }

  console.log(`🚀 Impostazione admin per UID: ${UID_DA_PROMUOVERE}`);
  console.log(`🎯 Admin: ${SET_AS_ADMIN ? 'ATTIVA' : 'DISATTIVA'}\n`);

  await setAdmin(UID_DA_PROMUOVERE, SET_AS_ADMIN);
  
  console.log('\n✨ Operazione completata con successo!');
  process.exit(0);
}

// Esegui lo script
main().catch(err => {
  console.error('💥 Errore fatale:', err);
  process.exit(1);
});
