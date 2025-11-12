# 🔐 Configurazione Restrizioni Google Maps API Key - MY PET CARE

## 📋 Dati Estratti dal Progetto

### 🤖 Android
- **Package Name**: `it.mypetcare.my_pet_care`
- **SHA-1 Fingerprint**: ⚠️ **DA OTTENERE SUL TUO COMPUTER** (vedi sotto)

### 🍎 iOS
- **Bundle ID**: `it.mypetcare.myPetCare`

### 🌐 Web
- **Domini Sviluppo**:
  - `localhost:*`
  - `127.0.0.1:*`
  - `localhost:52000`
  - `localhost:5060`
- **Domini Produzione**:
  - `mypetcare.it/*`
  - `www.mypetcare.it/*`
  - `app.mypetcare.it/*`

---

## 🔑 API Key Attuale

```
AIzaSyA07ds8t5-ovEi1UA5MQqCO5OQyQ7W08bM
```

**⚠️ ATTENZIONE**: Questa chiave è attualmente **NON RISTRETTA**. Chiunque può usarla e generare costi sul tuo account Google Cloud!

---

## 1️⃣ Android - Ottenere SHA-1 Fingerprint

### Metodo A: Tramite Gradlew (Consigliato)

**Sul tuo computer locale**, nella directory del progetto Flutter:

```bash
cd android
./gradlew signingReport
```

**Output Esempio**:
```
Variant: debug
Config: debug
Store: /Users/antonio/.android/debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
Valid until: ...

Variant: release
Config: release
[...release keystore info...]
```

**Copia il valore SHA1 della riga "Variant: debug"** (esempio: `A1:B2:C3:...`)

### Metodo B: Tramite Keytool

**Debug Keystore** (per sviluppo):
```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

**Release Keystore** (per produzione):
```bash
keytool -list -v -keystore /path/to/your/upload-keystore.jks \
  -alias your-key-alias
```

**Trova la riga con SHA1 e copia il valore** (formato: `XX:XX:XX:...`)

---

## 2️⃣ Google Cloud Console - Configurazione Restrizioni

### Accesso

1. Vai a: **https://console.cloud.google.com/**
2. Seleziona il progetto: **"MY PET CARE"**
3. Menu → **APIs & Services** → **Credentials**
4. Trova la chiave: `AIzaSyA07ds8t5-ovEi1UA5MQqCO5OQyQ7W08bM`
5. Click sull'icona **✏️ Edit**

---

## 3️⃣ Configurazione Android

### Step 1: Application Restrictions

Nella pagina "Edit API Key":

1. Sezione **Application restrictions**
2. Seleziona: ✅ **Android apps**
3. Click **+ ADD AN ITEM**

### Step 2: Aggiungi Restrizione Debug

**Per sviluppo locale**:

```
Package name: it.mypetcare.my_pet_care
SHA-1 certificate fingerprint: [INCOLLA IL TUO SHA-1 DEBUG QUI]
```

**Esempio**:
```
Package name: it.mypetcare.my_pet_care
SHA-1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

Click **DONE**

### Step 3: Aggiungi Restrizione Release (IMPORTANTE!)

**Per pubblicazione Play Store**:

1. Click **+ ADD AN ITEM** di nuovo
2. Compila:
   ```
   Package name: it.mypetcare.my_pet_care
   SHA-1: [SHA-1 DEL TUO RELEASE KEYSTORE]
   ```

**Come ottenere SHA-1 release**:
```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload
```

### Step 4: API Restrictions

Scroll giù a **API restrictions**:

1. Seleziona: ✅ **Restrict key**
2. Click **Select APIs**
3. Abilita **SOLO queste API**:
   - ✅ **Maps SDK for Android**
   - ✅ **Places API** (se usi autocomplete indirizzi)
   - ✅ **Geocoding API** (se converti coordinate → indirizzi)

### Step 5: Salva

Click **SAVE** in alto

---

## 4️⃣ Configurazione iOS

### Step 1: Application Restrictions

Nella stessa pagina (o crea nuova chiave):

1. Sezione **Application restrictions**
2. Seleziona: ✅ **iOS apps**
3. Click **+ ADD AN ITEM**

### Step 2: Aggiungi Bundle ID

```
Bundle ID: it.mypetcare.myPetCare
```

Click **DONE**

### Step 3: API Restrictions

1. Seleziona: ✅ **Restrict key**
2. Abilita **SOLO queste API**:
   - ✅ **Maps SDK for iOS**
   - ✅ **Places API** (se usi autocomplete indirizzi)
   - ✅ **Geocoding API** (se converti coordinate → indirizzi)

### Step 4: Salva

Click **SAVE**

---

## 5️⃣ Configurazione Web

### Step 1: Application Restrictions

Nella stessa pagina (o crea nuova chiave):

1. Sezione **Application restrictions**
2. Seleziona: ✅ **HTTP referrers (web sites)**
3. Click **+ ADD AN ITEM**

### Step 2: Aggiungi Domini

**Sviluppo Locale**:
```
localhost:*
127.0.0.1:*
```

**Produzione** (quando deploy):
```
mypetcare.it/*
www.mypetcare.it/*
app.mypetcare.it/*
```

**Esempio configurazione completa**:
```
localhost:*
127.0.0.1:*
mypetcare.it/*
*.mypetcare.it/*
```

### Step 3: API Restrictions

1. Seleziona: ✅ **Restrict key**
2. Abilita **SOLO queste API**:
   - ✅ **Maps JavaScript API**
   - ✅ **Places API** (se usi autocomplete indirizzi)
   - ✅ **Geocoding API** (se converti coordinate → indirizzi)

### Step 4: Salva

Click **SAVE**

---

## 🎯 Strategia Consigliata: 3 Chiavi Separate

Per **massima sicurezza**, crea **3 chiavi diverse**:

### Chiave 1: Android
```
Nome: MY_PET_CARE_ANDROID
Restrizioni: Android apps
  - Package: it.mypetcare.my_pet_care
  - SHA-1 Debug: [tuo SHA-1 debug]
  - SHA-1 Release: [tuo SHA-1 release]
API: Maps SDK for Android
```

### Chiave 2: iOS
```
Nome: MY_PET_CARE_IOS
Restrizioni: iOS apps
  - Bundle ID: it.mypetcare.myPetCare
API: Maps SDK for iOS
```

### Chiave 3: Web
```
Nome: MY_PET_CARE_WEB
Restrizioni: HTTP referrers
  - localhost:*
  - *.mypetcare.it/*
API: Maps JavaScript API
```

### Implementazione nel Codice

**Android** (`AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyA_ANDROID_KEY_HERE" />
```

**iOS** (`Info.plist`):
```xml
<key>GMSApiKey</key>
<string>AIzaSyA_IOS_KEY_HERE</string>
```

**Web** (`index.html`):
```html
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA_WEB_KEY_HERE"></script>
```

---

## ✅ Verifica Configurazione

### Test Android

1. Build APK: `flutter build apk`
2. Installa su device: `flutter install`
3. Apri app → HomeMapPage
4. **Verifica**: Mappa carica correttamente
5. **Se errore 403**: Controlla SHA-1 e package name

### Test iOS

1. Build iOS: `flutter build ios`
2. Apri in Xcode: `open ios/Runner.xcworkspace`
3. Run su device/simulator
4. **Verifica**: Mappa carica correttamente
5. **Se errore 403**: Controlla Bundle ID

### Test Web

1. Build Web: `flutter build web --release`
2. Serve localmente: `python3 -m http.server 5060 --directory build/web`
3. Apri browser: `http://localhost:5060`
4. **Verifica**: Mappa carica correttamente
5. **Se errore 403**: Controlla HTTP referrers

---

## 🚨 Risoluzione Errori Comuni

### Errore 403: "This API key is not authorized to use this service or API"

**Causa**: Restrizioni API Key non corrispondono

**Android**:
- ✅ Verifica SHA-1 corretto (debug vs release)
- ✅ Verifica package name esatto
- ✅ Verifica "Maps SDK for Android" abilitata

**iOS**:
- ✅ Verifica Bundle ID esatto (case-sensitive!)
- ✅ Verifica "Maps SDK for iOS" abilitata

**Web**:
- ✅ Verifica dominio in lista HTTP referrers
- ✅ Verifica "Maps JavaScript API" abilitata
- ✅ Controlla porta (es: localhost:5060 vs localhost:*)

### Errore: "The Google Play services resources were not found"

**Causa**: Google Play Services non installato su device

**Soluzione**:
- Usa device con Google Play Services
- Oppure emulator con Google APIs

---

## 📊 Monitoraggio Utilizzo

### Google Cloud Console

1. Menu → **APIs & Services** → **Dashboard**
2. Seleziona API: **"Maps SDK for Android/iOS/JavaScript"**
3. Visualizza:
   - Richieste totali
   - Richieste per giorno
   - Errori (4xx, 5xx)
   - Latenza media

### Alert Billing

1. Menu → **Billing** → **Budgets & alerts**
2. **Create Budget**:
   - Nome: "MY PET CARE - Maps API Alert"
   - Budget amount: **$50 / mese**
   - Alert threshold: **50%, 80%, 100%**
   - Email notifications: ✅ Abilita

---

## 💰 Costi Stimati (Dopo Quota Gratuita)

**Quota Gratuita Mensile**: $200 di credito Google Maps Platform

### Costi per 1.000 richieste
- **Maps SDK for Android**: ~$7
- **Maps SDK for iOS**: ~$7
- **Maps JavaScript API**: ~$7
- **Places API**: ~$17
- **Geocoding API**: ~$5

### Esempio Utilizzo
```
1.000 utenti/giorno × 30 giorni = 30.000 richieste/mese
Costo: ~$200/mese (coperto da quota gratuita)

5.000 utenti/giorno × 30 giorni = 150.000 richieste/mese
Costo: ~$1.050/mese ($850 oltre quota gratuita)
```

---

## 🔗 Link Utili

- **Google Cloud Console**: https://console.cloud.google.com/
- **Pricing Calculator**: https://mapsplatform.google.com/pricing/
- **Documentation**: https://developers.google.com/maps/documentation
- **API Dashboard**: https://console.cloud.google.com/apis/dashboard
- **Billing**: https://console.cloud.google.com/billing

---

## 📝 Checklist Pre-Produzione

Prima di pubblicare su App Store / Play Store:

- [ ] ✅ SHA-1 fingerprint **release** ottenuto
- [ ] ✅ Restrizione Android configurata (package + SHA-1 release)
- [ ] ✅ Restrizione iOS configurata (Bundle ID)
- [ ] ✅ Restrizione Web configurata (domini produzione)
- [ ] ✅ API restrictions attive (solo Maps SDK necessarie)
- [ ] ✅ Alert billing configurati ($50, $100, $150)
- [ ] ✅ Test completo su device fisico
- [ ] ✅ Test mappa funzionante con API ristretta
- [ ] ✅ Monitoraggio quota attivo
- [ ] ✅ Team informato su costi potenziali

---

## 🎯 Comandi Rapidi

```bash
# Android SHA-1 (debug)
cd android && ./gradlew signingReport

# Android SHA-1 (release keystore)
keytool -list -v -keystore ~/upload-keystore.jks -alias upload

# iOS Bundle ID
grep -A1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -2

# Android Package Name
grep "applicationId" android/app/build.gradle.kts

# Test build Android
flutter build apk --release

# Test build iOS
flutter build ios --release

# Test Web locale
flutter build web --release && python3 -m http.server 5060 --directory build/web
```

---

**🔐 Configura le restrizioni PRIMA del deploy in produzione per evitare sorprese sui costi!**
