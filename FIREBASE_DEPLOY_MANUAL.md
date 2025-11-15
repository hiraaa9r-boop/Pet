# 🚀 Firebase Hosting - Guida Deploy Manuale MyPetCare

## 📊 Stato Build

✅ **Build Web Completato:**
- **Dimensione originale:** 31 MB
- **Archivio compresso (tar.gz):** 11 MB
- **Archivio compresso (zip):** 11 MB
- **Location:** `/home/user/flutter_app/build/web/`

✅ **Firebase Configurato:**
- **Progetto:** `pet-care-9790d`
- **Dominio atteso:** `pet-care-9790d.web.app` o `pet-care-9790d.firebaseapp.com`
- **Config:** `firebase.json` + `.firebaserc` pronti

---

## 🌐 METODO 1: Deploy via Firebase Console (RACCOMANDATO)

### **Step 1: Accedi a Firebase Console**

Vai su: **https://console.firebase.google.com/project/pet-care-9790d/hosting**

### **Step 2: Seleziona Hosting**

1. Nel menu laterale clicca **"Hosting"**
2. Dovresti vedere la sezione "Get started" o deploy esistenti

### **Step 3: Deploy Manuale**

#### **Opzione A: Drag & Drop (Più Semplice)**

1. Clicca su **"Add another site"** (se non hai deploy) oppure **"Deploy to site"**
2. Seleziona **"Manual deployment"**
3. **Trascina la cartella** `/home/user/flutter_app/build/web/` direttamente nel browser
   - **IMPORTANTE:** Trascina la cartella `web`, NON l'archivio .zip/.tar.gz
   - La cartella contiene: `index.html`, `main.dart.js`, `assets/`, ecc.

#### **Opzione B: Upload Archivio**

Se il drag & drop non funziona:

1. Scarica l'archivio dal sandbox:
   - **TAR.GZ:** `/home/user/flutter_app/mypetcare_web_build.tar.gz` (11 MB)
   - **ZIP:** `/home/user/flutter_app/mypetcare_web_build.zip` (11 MB)

2. Estrai l'archivio sul tuo computer locale:
   ```bash
   # Su Linux/Mac
   tar -xzf mypetcare_web_build.tar.gz
   
   # Su Windows
   # Usa 7-Zip o WinRAR per estrarre
   ```

3. Nella Firebase Console, trascina la cartella `web/` estratta

### **Step 4: Conferma Deploy**

1. Firebase caricherà i file (può richiedere 2-5 minuti)
2. Vedrai una progress bar
3. Al termine, Firebase mostrerà l'URL del deploy:
   - `https://pet-care-9790d.web.app`
   - `https://pet-care-9790d.firebaseapp.com`

### **Step 5: Verifica Deploy**

Apri l'URL in un browser e verifica:
- ✅ Logo MyPetCare visibile
- ✅ Splash screen funzionante
- ✅ Navigazione al login
- ✅ Nessun errore console

---

## 💻 METODO 2: Deploy via Firebase CLI (Richiede Autenticazione)

**⚠️ LIMITAZIONE SANDBOX:** Il sandbox non può eseguire `firebase login` interattivo (richiede browser OAuth).

### **Se hai Firebase CLI sul tuo computer locale:**

```bash
# 1. Scarica il progetto dal sandbox (incluso build/web)

# 2. Sul tuo computer, naviga nella cartella del progetto
cd /path/to/flutter_app

# 3. Accedi a Firebase (apre browser per OAuth)
firebase login

# 4. Verifica progetto
firebase projects:list
# Dovresti vedere: pet-care-9790d

# 5. Deploy
firebase deploy --only hosting

# 6. Output atteso:
# ✔  Deploy complete!
# Project Console: https://console.firebase.google.com/project/pet-care-9790d/overview
# Hosting URL: https://pet-care-9790d.web.app
```

---

## 🔧 METODO 3: Deploy via CI/CD Token (Avanzato)

Se vuoi automatizzare il deploy senza browser:

### **Step 1: Genera Token CI/CD**

Sul tuo computer con Firebase CLI:

```bash
firebase login:ci
```

Questo aprirà il browser, autentica e genera un token come:
```
1//XXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### **Step 2: Usa Token nel Sandbox**

**⚠️ NON committare il token nel repository!**

```bash
# Nel sandbox, usa il token per deploy
cd /home/user/flutter_app

# Deploy con token
firebase deploy --only hosting --token "1//XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

---

## 📋 Verifica Pre-Deploy

Prima di caricare, verifica che il build contenga:

```bash
cd /home/user/flutter_app/build/web

# File principali richiesti
ls -la | grep -E "index.html|main.dart.js|flutter_service_worker.js|manifest.json"

# Output atteso:
# -rw-r--r-- index.html
# -rw-r--r-- main.dart.js (2.8 MB)
# -rw-r--r-- flutter_service_worker.js
# -rw-r--r-- manifest.json
```

✅ **Tutti i file presenti!**

---

## 🌍 URL Finali Post-Deploy

Dopo il deploy, l'app sarà disponibile su:

1. **URL Primario:**
   - `https://pet-care-9790d.web.app`

2. **URL Alternativo:**
   - `https://pet-care-9790d.firebaseapp.com`

3. **Custom Domain (Da Configurare):**
   - `https://app.mypetcareapp.org`
   - Richiede configurazione DNS e verifica dominio

---

## 🔗 Custom Domain Setup (Opzionale)

Se vuoi usare `app.mypetcareapp.org`:

### **Step 1: Aggiungi Custom Domain in Firebase**

1. Firebase Console → Hosting → **"Add custom domain"**
2. Inserisci: `app.mypetcareapp.org`
3. Firebase ti darà record DNS da configurare

### **Step 2: Configura DNS (Cloudflare/altro provider)**

Firebase ti chiederà di aggiungere record tipo:

**Opzione A - Record A:**
```
Type: A
Name: app
Value: 151.101.1.195 (esempio, usa quello fornito da Firebase)
```

**Opzione B - Record CNAME:**
```
Type: CNAME
Name: app
Value: hosting.app.goog
```

### **Step 3: Verifica Dominio**

Firebase verificherà il dominio (può richiedere fino a 24 ore). Una volta verificato, genererà automaticamente un certificato SSL.

---

## 🧪 Test Post-Deploy

Dopo il deploy, testa:

1. **Homepage / Splash:**
   - `https://pet-care-9790d.web.app/`
   - Dovrebbe mostrare logo MyPetCare

2. **Login:**
   - `https://pet-care-9790d.web.app/login`
   - Form login funzionante

3. **Routing:**
   - Prova navigazione tra pagine
   - Verifica che URL puliti funzionino (grazie a `cleanUrls: true`)

4. **Console Browser:**
   - F12 → Console
   - Verifica nessun errore critico
   - Warning Firebase ok (normali in dev)

5. **Mobile:**
   - Testa su dispositivo mobile
   - Responsive design
   - PWA manifest (installabile come app)

---

## 📊 Statistiche Build Corrente

```
Build Directory: /home/user/flutter_app/build/web/
Size: 31 MB (uncompressed)
Compressed: 11 MB (.tar.gz / .zip)

File Structure:
├── index.html (517 bytes)
├── main.dart.js (2.8 MB) ← App code
├── flutter_service_worker.js (9.8 KB) ← PWA
├── flutter.js (9.1 KB)
├── flutter_bootstrap.js (9.4 KB)
├── manifest.json (963 bytes) ← PWA manifest
├── version.json (94 bytes)
├── favicon.png (1.3 KB)
├── assets/ (fonts, images, etc.)
├── canvaskit/ (Flutter rendering engine)
├── icons/ (app icons)
└── splash/ (splash screens)
```

---

## ⚠️ Troubleshooting

### **Problema: "Deploy non trovato su Firebase Console"**

**Causa:** Prima volta che usi Firebase Hosting su questo progetto.

**Soluzione:**
1. Firebase Console → Hosting
2. Click **"Get started"**
3. Segui wizard iniziale
4. Poi usa "Manual deployment"

### **Problema: "Firebase mostra pagina vuota"**

**Causa:** Flutter router non configurato correttamente o file mancanti.

**Verifica:**
```bash
cd /home/user/flutter_app/build/web
ls -la index.html main.dart.js
```

Se i file ci sono, il problema è nel routing. Verifica che `firebase.json` abbia:
```json
"rewrites": [
  {
    "source": "**",
    "destination": "/index.html"
  }
]
```

### **Problema: "Errore 404 su route /login"**

**Causa:** `cleanUrls` o rewrites non configurati.

**Soluzione:** Già presente in `firebase.json` ✅

### **Problema: "App funziona ma URL mostra 'app.firebaseapp.com'"**

**Soluzione:** Normale! Firebase fornisce due URL di default. Per custom domain (app.mypetcareapp.org), segui la sezione "Custom Domain Setup".

---

## 📚 Risorse Firebase

- **Firebase Console:** https://console.firebase.google.com/project/pet-care-9790d
- **Hosting Dashboard:** https://console.firebase.google.com/project/pet-care-9790d/hosting
- **Firebase Docs:** https://firebase.google.com/docs/hosting
- **Custom Domain Guide:** https://firebase.google.com/docs/hosting/custom-domain

---

## ✅ Checklist Deploy

**Pre-Deploy:**
- [x] Build web completato (31 MB)
- [x] Archivi compressi creati (.tar.gz + .zip)
- [x] `firebase.json` configurato
- [x] `.firebaserc` con progetto corretto
- [x] File principali verificati (index.html, main.dart.js, ecc.)

**Deploy:**
- [ ] Accesso Firebase Console completato
- [ ] Upload build/web/ tramite drag & drop
- [ ] Deploy confermato (progress 100%)
- [ ] URL deploy ricevuto

**Post-Deploy:**
- [ ] Homepage accessibile e funzionante
- [ ] Login form visibile e funzionante
- [ ] Routing tra pagine ok
- [ ] Nessun errore console critico
- [ ] Test su mobile device
- [ ] PWA manifest configurato
- [ ] (Opzionale) Custom domain configurato

---

## 🎯 Prossimi Step Dopo Deploy

1. **✅ Verifica app live** su URL Firebase
2. **🔒 Configura Firestore Security Rules** (attualmente in test mode)
3. **🌐 Setup Custom Domain** (app.mypetcareapp.org)
4. **📊 Abilita Firebase Analytics** per monitoraggio
5. **🚀 Deploy Backend** su Cloud Run (api.mypetcareapp.org)
6. **💳 Configura Stripe/PayPal** LIVE (attualmente placeholder)
7. **📧 Test Email Verification** (Firebase Auth)
8. **🔔 Test Push Notifications** (FCM)

---

**🎉 BUILD PRONTO E OTTIMIZZATO PER IL DEPLOY!**

Archivi disponibili in:
- `/home/user/flutter_app/mypetcare_web_build.tar.gz` (11 MB)
- `/home/user/flutter_app/mypetcare_web_build.zip` (11 MB)

Carica su Firebase Console per completare il deploy! 🚀
