# 🚀 MyPetCare - Deployment Instructions

Istruzioni complete per il deployment delle nuove funzionalità implementate:
- **Feature 1**: Booking Reminders (24h automatici)
- **Feature 2**: Sistema Chat In-App
- **Feature 3**: Admin Dashboard Enhancements (Grafico + Export CSV)

---

## 📋 Modifiche Implementate

### Backend (TypeScript/Express)
1. ✅ **`/backend/src/routes/jobs.ts`** (8,790 caratteri) - Nuovo file
   - Endpoint `/jobs/send-reminders` per reminder automatici 24h prima
   - Endpoint `/jobs/cleanup-locks` per pulizia lock scaduti
   - Protezione con `CRON_SECRET` middleware

2. ✅ **`/backend/src/routes/messages.ts`** (11,849 caratteri) - Nuovo file
   - Sistema chat completo con 5 endpoint REST
   - Conversation ID deterministico (user IDs ordinati)
   - FCM notifications integrate
   - Paginazione messaggi

3. ✅ **`/backend/src/routes/admin.ts`** - Modificato
   - Aggiunto endpoint `/admin/export/payments.csv`
   - Export CSV manuale (no dipendenze esterne)

4. ✅ **`/backend/src/index.ts`** - Modificato
   - Montati routes `/jobs` e `/messages`

### Frontend (Flutter/Dart)
5. ✅ **`/lib/features/chat/chat_screen.dart`** (12,169 caratteri) - Nuovo file
   - UI chat real-time con StreamBuilder
   - Auto-scroll e mark-as-read
   - Message bubbles con timestamp

6. ✅ **`/lib/features/admin/analytics_page.dart`** - Modificato
   - Aggiunto grafico trend entrate (fl_chart LineChart)
   - Pulsante "Esporta Pagamenti CSV" con url_launcher

### Configurazione Firebase
7. ✅ **`firestore.indexes.json`** - Aggiornato
   - Indice composite per booking reminders
   - Indice per messages (createdAt DESC)
   - Indice per threads (users array + lastMessage.at)

8. ✅ **`firestore.rules`** - Aggiornato
   - Regole sicurezza per collection `threads`
   - Regole sicurezza per subcollection `messages`

### Dipendenze
9. ✅ **`pubspec.yaml`** - Aggiornato
   - Aggiunto `fl_chart: ^0.69.0`
   - `url_launcher` già presente

---

## 🔧 Step 1: Deploy Backend su Cloud Run

### 1.1 Compilare TypeScript
```bash
cd /home/user/flutter_app/backend
npm run build
```

### 1.2 Configurare Variabili d'Ambiente
Aggiungi le seguenti variabili al tuo Cloud Run service:

```bash
# Variabile CRITICA per proteggere endpoint jobs
CRON_SECRET="your-random-secret-here-min-32-chars"

# Esempio generazione secret sicuro:
openssl rand -base64 32
```

**Impostare su Cloud Run:**
```bash
gcloud run services update mypetcare-backend \
  --region=europe-west1 \
  --update-env-vars CRON_SECRET="your-generated-secret-here"
```

### 1.3 Deploy Backend
```bash
gcloud run deploy mypetcare-backend \
  --source=. \
  --region=europe-west1 \
  --platform=managed \
  --allow-unauthenticated
```

---

## ⏰ Step 2: Configurare Cloud Scheduler

### 2.1 Creare Job per Booking Reminders

**Prerequisito**: Abilita Cloud Scheduler API
```bash
gcloud services enable cloudscheduler.googleapis.com
```

**Crea Scheduled Job (esegue ogni ora):**
```bash
gcloud scheduler jobs create http booking-reminders \
  --location=europe-west1 \
  --schedule="0 * * * *" \
  --uri="https://mypetcare-backend-YOUR-PROJECT.run.app/jobs/send-reminders" \
  --http-method=POST \
  --headers="X-Cron-Secret=your-generated-secret-here,Content-Type=application/json" \
  --oidc-service-account-email=YOUR-SERVICE-ACCOUNT@YOUR-PROJECT.iam.gserviceaccount.com \
  --oidc-token-audience=https://mypetcare-backend-YOUR-PROJECT.run.app
```

**Sostituisci:**
- `YOUR-PROJECT` con il tuo GCP Project ID
- `your-generated-secret-here` con lo stesso secret usato in CRON_SECRET
- `YOUR-SERVICE-ACCOUNT@...` con il service account Cloud Run

### 2.2 Creare Job per Lock Cleanup (Opzionale ma Raccomandato)

```bash
gcloud scheduler jobs create http cleanup-locks \
  --location=europe-west1 \
  --schedule="*/15 * * * *" \
  --uri="https://mypetcare-backend-YOUR-PROJECT.run.app/jobs/cleanup-locks" \
  --http-method=POST \
  --headers="X-Cron-Secret=your-generated-secret-here,Content-Type=application/json" \
  --oidc-service-account-email=YOUR-SERVICE-ACCOUNT@YOUR-PROJECT.iam.gserviceaccount.com \
  --oidc-token-audience=https://mypetcare-backend-YOUR-PROJECT.run.app
```

**Nota**: Questo job esegue ogni 15 minuti per pulire lock scaduti.

---

## 🔥 Step 3: Deploy Firestore Configuration

### 3.1 Deploy Firestore Indexes
```bash
cd /home/user/flutter_app
firebase deploy --only firestore:indexes
```

**Tempo stimato**: 5-10 minuti per la creazione degli indici.

**Verifica indici creati:**
```
https://console.firebase.google.com/project/YOUR-PROJECT/firestore/indexes
```

### 3.2 Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

**Verifica regole attive:**
```
https://console.firebase.google.com/project/YOUR-PROJECT/firestore/rules
```

---

## 📱 Step 4: Deploy Flutter App

### 4.1 Aggiornare Costanti API
Modifica `/lib/features/chat/chat_screen.dart` e `/lib/features/admin/analytics_page.dart`:

```dart
// Sostituisci con il tuo URL Cloud Run effettivo
const String kApiBase = "https://mypetcare-backend-YOUR-PROJECT.run.app";
```

### 4.2 Build Android APK
```bash
cd /home/user/flutter_app
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 4.3 Build iOS (se necessario)
```bash
flutter build ios --release
```

---

## 🧪 Step 5: Testing delle Nuove Funzionalità

### 5.1 Test Booking Reminders

**Test Manuale dell'Endpoint:**
```bash
curl -X POST https://mypetcare-backend-YOUR-PROJECT.run.app/jobs/send-reminders \
  -H "X-Cron-Secret: your-generated-secret-here" \
  -H "Content-Type: application/json"
```

**Risposta attesa:**
```json
{
  "ok": true,
  "sent": 5,
  "errors": 0
}
```

**Verifica in Firestore:**
- Controlla collection `bookings` → campo `reminderSent: true`

**Verifica FCM Notifications:**
- Controlla dispositivi con FCM tokens registrati
- Verifica ricezione notifica "🔔 Promemoria Prenotazione"

### 5.2 Test Sistema Chat

**A) Creare Thread di Chat:**
```bash
curl -X POST https://mypetcare-backend-YOUR-PROJECT.run.app/messages/thread \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user_123",
    "proId": "pro_456"
  }'
```

**B) Inviare Messaggio:**
```bash
curl -X POST https://mypetcare-backend-YOUR-PROJECT.run.app/messages/user_123_pro_456/send \
  -H "Content-Type: application/json" \
  -d '{
    "from": "user_123",
    "to": "pro_456",
    "text": "Ciao! Vorrei prenotare un appuntamento."
  }'
```

**C) Recuperare Messaggi:**
```bash
curl -X GET https://mypetcare-backend-YOUR-PROJECT.run.app/messages/user_123_pro_456?limit=20
```

**D) Test UI Flutter:**
1. Apri app su due dispositivi (user e pro)
2. Naviga a `ChatScreen(meId: 'user_123', peerId: 'pro_456', peerName: 'Mario PRO')`
3. Invia messaggi da entrambi i dispositivi
4. Verifica aggiornamento real-time con StreamBuilder

### 5.3 Test Admin Dashboard

**A) Test Grafico Revenue:**
1. Login come admin nell'app Flutter
2. Naviga a `/admin/analytics`
3. Verifica visualizzazione grafico LineChart con 7 giorni

**B) Test Export CSV:**
1. Click sul pulsante "Esporta Pagamenti CSV"
2. Verifica download automatico del file CSV
3. Apri CSV e verifica colonne: id, userId, provider, amount, currency, createdAt, receiptUrl

**C) Test API diretto:**
```bash
curl -X GET https://mypetcare-backend-YOUR-PROJECT.run.app/admin/export/payments.csv \
  -H "Authorization: Bearer YOUR-ADMIN-TOKEN"
```

---

## 📊 Step 6: Monitoring e Logs

### 6.1 Cloud Scheduler Logs
```bash
# Visualizza log dei job schedulati
gcloud scheduler jobs describe booking-reminders --location=europe-west1

# Visualizza esecuzioni recenti
gcloud logging read "resource.type=cloud_scheduler_job AND resource.labels.job_id=booking-reminders" --limit 50
```

### 6.2 Cloud Run Logs
```bash
# Visualizza log backend in tempo reale
gcloud run logs tail mypetcare-backend --region=europe-west1

# Filtra per jobs
gcloud run logs read mypetcare-backend --region=europe-west1 --filter='jsonPayload.route="/jobs/send-reminders"'

# Filtra per messages
gcloud run logs read mypetcare-backend --region=europe-west1 --filter='jsonPayload.route="/messages"'
```

### 6.3 Firestore Usage
Monitora utilizzo indici e query:
```
https://console.firebase.google.com/project/YOUR-PROJECT/firestore/usage
```

---

## 🔒 Sicurezza e Best Practices

### 6.1 CRON_SECRET Protection
- **CRITICO**: Non committare CRON_SECRET in repository
- Usa Google Secret Manager per produzione:
  ```bash
  echo -n "your-secret" | gcloud secrets create cron-secret --data-file=-
  
  gcloud run services update mypetcare-backend \
    --update-secrets=CRON_SECRET=cron-secret:latest
  ```

### 6.2 Firebase Security Rules
- Le regole implementate garantiscono:
  - ✅ Solo partecipanti possono leggere messaggi
  - ✅ Campo `from` deve corrispondere a auth.uid
  - ✅ ThreadId deterministico previene duplicati
  - ✅ Admin può eliminare thread inappropriati

### 6.3 Rate Limiting (Raccomandato)
Aggiungi rate limiting agli endpoint messages in `backend/src/index.ts`:
```typescript
import rateLimit from 'express-rate-limit';

const messagesLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minuto
  max: 30, // max 30 messaggi al minuto per IP
  message: 'Troppi messaggi, riprova tra un minuto'
});

app.use('/messages', messagesLimiter, messagesRouter);
```

---

## 📈 Metriche di Successo

Dopo il deployment, monitora:

### Booking Reminders
- ✅ **Tasso di invio**: `bookings con reminderSent=true / bookings totali`
- ✅ **Delivery rate FCM**: logs backend per failed notifications
- ✅ **Riduzione no-show**: confronta tasso no-show pre/post implementazione

### Sistema Chat
- ✅ **Thread attivi**: count collection `threads`
- ✅ **Messaggi giornalieri**: aggregate messages by day
- ✅ **Tempo di risposta medio**: differenza timestamp tra messaggi user-pro

### Admin Dashboard
- ✅ **Export CSV usage**: count download requests
- ✅ **Admin active sessions**: Firebase Analytics custom events

---

## 🐛 Troubleshooting

### Problema: Reminder non vengono inviati
**Causa possibile**: CRON_SECRET non corrisponde
**Soluzione**:
```bash
# Verifica secret in Cloud Run
gcloud run services describe mypetcare-backend --region=europe-west1 --format='value(spec.template.spec.containers[0].env[?name=="CRON_SECRET"].value)'

# Verifica header in Cloud Scheduler
gcloud scheduler jobs describe booking-reminders --location=europe-west1 --format='value(httpTarget.headers)'
```

### Problema: Messaggi non appaiono in chat
**Causa possibile**: Indici Firestore non pronti
**Soluzione**:
```bash
# Controlla stato indici
firebase deploy --only firestore:indexes --project YOUR-PROJECT

# Verifica in console
https://console.firebase.google.com/project/YOUR-PROJECT/firestore/indexes
```

### Problema: CSV export non funziona
**Causa possibile**: CORS o autenticazione
**Soluzione**:
- Verifica header `Authorization` nel request
- Controlla CORS settings in backend index.ts
- Test diretto con curl + admin token

### Problema: Firestore permission denied
**Causa possibile**: Regole security troppo restrittive
**Soluzione**:
```bash
# Verifica regole attuali
firebase firestore:rules --project YOUR-PROJECT

# Test simulator nella console
https://console.firebase.google.com/project/YOUR-PROJECT/firestore/rules
```

---

## 📞 Support e Riferimenti

### Documentazione Tecnica
- **Cloud Scheduler**: https://cloud.google.com/scheduler/docs
- **Firebase FCM**: https://firebase.google.com/docs/cloud-messaging
- **Firestore Indexes**: https://firebase.google.com/docs/firestore/query-data/indexing
- **fl_chart**: https://pub.dev/packages/fl_chart

### File Modificati in Questo Deploy
```
backend/src/routes/jobs.ts           (nuovo)
backend/src/routes/messages.ts       (nuovo)
backend/src/routes/admin.ts          (modificato)
backend/src/index.ts                 (modificato)
lib/features/chat/chat_screen.dart   (nuovo)
lib/features/admin/analytics_page.dart (modificato)
firestore.indexes.json               (modificato)
firestore.rules                      (modificato)
pubspec.yaml                         (modificato)
```

---

## ✅ Checklist Finale

Prima di considerare il deployment completo, verifica:

- [ ] Backend deployato su Cloud Run con successo
- [ ] Variabile CRON_SECRET configurata
- [ ] Cloud Scheduler jobs creati e attivi
- [ ] Firestore indexes deployati (status: READY)
- [ ] Firestore rules deployate e testate
- [ ] Flutter app compilata e testata in staging
- [ ] Test manuale booking reminders con curl
- [ ] Test manuale chat API con curl
- [ ] Test UI chat su 2 dispositivi diversi
- [ ] Test export CSV da admin dashboard
- [ ] Logs monitoring configurato
- [ ] Alert configurati per job failures (opzionale)

---

**Deployment completato con successo! 🎉**

Per domande o supporto, riferirsi alla documentazione sopra o contattare il team di sviluppo.
