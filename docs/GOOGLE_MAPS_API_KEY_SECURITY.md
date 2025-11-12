# 🔐 Sicurezza Google Maps API Key - MY PET CARE

## ⚠️ IMPORTANTE: Restrizioni API Key

**API Key Attuale (NON PROTETTA)**: `AIzaSyA07ds8t5-ovEi1UA5MQqCO5OQyQ7W08bM`

Questa chiave è attualmente **NON RISTRETTA** e può essere usata da chiunque. Prima di pubblicare l'app in produzione, **DEVI configurare le restrizioni** per evitare abusi e costi imprevisti.

---

## 📋 Step di Sicurezza Obbligatori

### 1. Accedi a Google Cloud Console

1. Vai a: https://console.cloud.google.com/
2. Seleziona il progetto "MY PET CARE"
3. Menu → **API & Services** → **Credentials**
4. Trova la chiave: `AIzaSyA07ds8t5-ovEi1UA5MQqCO5OQyQ7W08bM`
5. Click sull'icona **✏️ Edit**

---

## 🤖 Restrizioni Android

### Step 1: Ottieni SHA-1 Certificate Fingerprint

```bash
cd android
./gradlew signingReport
```

**Output Esempio**:
```
Variant: debug
Config: debug
Store: ~/.android/debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
SHA-256: XX:XX:XX:...
```

### Step 2: Configura Restrizioni

Nella pagina "Edit API Key":

1. **Application restrictions**:
   - Seleziona: ✅ **Android apps**
   
2. **Add an item**:
   - **Package name**: `com.example.my_pet_care` (vedi AndroidManifest.xml)
   - **SHA-1 certificate fingerprint**: Incolla valore ottenuto (es: `A1:B2:C3:...`)
   
3. **Per produzione**, ripeti aggiungendo SHA-1 del release keystore:
   ```bash
   keytool -list -v -keystore ~/upload-keystore.jks
   ```

### Step 3: API restrictions

Seleziona: ✅ **Restrict key**

Abilita **solo queste API**:
- ✅ Maps SDK for Android
- ✅ Places API (se usi autocomplete indirizzi)
- ✅ Geocoding API (se converti lat/lng → indirizzi)

**Salva** le modifiche.

---

## 🍎 Restrizioni iOS

### Step 1: Ottieni Bundle ID

Apri `ios/Runner.xcodeproj` in Xcode:
- Menu → **Runner** (progetto)
- Tab **General**
- Copia **Bundle Identifier** (es: `com.example.myPetCare`)

**Oppure** leggi da Info.plist:
```bash
grep -A1 "CFBundleIdentifier" ios/Runner/Info.plist
```

### Step 2: Configura Restrizioni

Nella pagina "Edit API Key":

1. **Application restrictions**:
   - Seleziona: ✅ **iOS apps**
   
2. **Add an item**:
   - **Bundle ID**: Incolla valore ottenuto (es: `com.example.myPetCare`)

### Step 3: API restrictions

Seleziona: ✅ **Restrict key**

Abilita **solo queste API**:
- ✅ Maps SDK for iOS
- ✅ Places API (se usi autocomplete indirizzi)
- ✅ Geocoding API (se converti lat/lng → indirizzi)

**Salva** le modifiche.

---

## 🌐 Restrizioni Web

### Step 1: Lista Domini Autorizzati

Prepara lista di domini che useranno l'app web:

**Sviluppo**:
- `localhost:*`
- `127.0.0.1:*`
- `localhost:52000` (Flutter debug)

**Produzione**:
- `mypetcare.it/*`
- `www.mypetcare.it/*`
- `app.mypetcare.it/*`

### Step 2: Configura Restrizioni

Nella pagina "Edit API Key":

1. **Application restrictions**:
   - Seleziona: ✅ **HTTP referrers (web sites)**
   
2. **Website restrictions**:
   - Aggiungi ogni dominio:
     ```
     localhost:*
     127.0.0.1:*
     mypetcare.it/*
     www.mypetcare.it/*
     app.mypetcare.it/*
     ```

### Step 3: API restrictions

Seleziona: ✅ **Restrict key**

Abilita **solo queste API**:
- ✅ Maps JavaScript API
- ✅ Places API (se usi autocomplete indirizzi)
- ✅ Geocoding API (se converti lat/lng → indirizzi)

**Salva** le modifiche.

---

## 📊 Strategia Multi-Key (Consigliata)

Per massima sicurezza, crea **3 chiavi separate**:

### Key 1: Android Only
```
Nome: MY_PET_CARE_ANDROID
Restrizioni: Android apps
Package: com.example.my_pet_care
SHA-1: [tuo SHA-1]
API: Maps SDK for Android
```

### Key 2: iOS Only
```
Nome: MY_PET_CARE_IOS
Restrizioni: iOS apps
Bundle ID: com.example.myPetCare
API: Maps SDK for iOS
```

### Key 3: Web Only
```
Nome: MY_PET_CARE_WEB
Restrizioni: HTTP referrers
Domini: mypetcare.it/*, localhost:*
API: Maps JavaScript API
```

**Implementazione**:
```dart
// lib/config.dart
const String googleMapsApiKeyAndroid = String.fromEnvironment(
  'GOOGLE_MAPS_ANDROID_KEY',
  defaultValue: 'AIzaSyA...',
);

const String googleMapsApiKeyIOS = String.fromEnvironment(
  'GOOGLE_MAPS_IOS_KEY',
  defaultValue: 'AIzaSyB...',
);

const String googleMapsApiKeyWeb = String.fromEnvironment(
  'GOOGLE_MAPS_WEB_KEY',
  defaultValue: 'AIzaSyC...',
);
```

---

## 🚨 Cosa Succede Senza Restrizioni?

### Rischi
- ❌ Chiunque può rubare la chiave e usarla
- ❌ Bot possono fare migliaia di richieste
- ❌ Costi imprevisti su Google Cloud ($$$)
- ❌ Superamento quota gratuita ($200/mese)
- ❌ Account Google Cloud sospeso

### Esempio Costo Abuso
```
10.000 richieste Maps API/giorno × 30 giorni = 300.000 richieste/mese
Costo: $1.500/mese (oltre quota gratuita)
```

---

## ✅ Checklist Pre-Produzione

Prima di pubblicare su App Store / Play Store:

- [ ] ✅ API Key Android ristretta (Package + SHA-1)
- [ ] ✅ API Key iOS ristretta (Bundle ID)
- [ ] ✅ API Key Web ristretta (Domini produzione)
- [ ] ✅ API restrictions attive (solo Maps SDK necessarie)
- [ ] ✅ Monitoraggio quote attivo (Google Cloud Console)
- [ ] ✅ Alert billing configurati ($50, $100, $150)
- [ ] ✅ Test completo su device reale
- [ ] ✅ Verifica permessi posizione funzionanti

---

## 🔍 Monitoraggio Utilizzo

### Google Cloud Console

1. Menu → **APIs & Services** → **Dashboard**
2. Seleziona API: "Maps SDK for Android/iOS/JavaScript"
3. Grafici disponibili:
   - **Requests** (richieste/giorno)
   - **Errors** (errori)
   - **Latency** (latenza)

### Alert Billing

1. Menu → **Billing** → **Budgets & alerts**
2. **Create Budget**:
   - Nome: "MY PET CARE Maps API Alert"
   - Budget amount: $50, $100, $150
   - Alert threshold: 50%, 80%, 100%
   - Email notifications: ✅

---

## 📞 Supporto

### Link Utili
- Google Cloud Console: https://console.cloud.google.com/
- Pricing Calculator: https://mapsplatform.google.com/pricing/
- Documentation: https://developers.google.com/maps/documentation

### Quota Gratuita Mensile
- **$200 di credito gratuito** ogni mese
- Maps SDK for Android: ~28.000 caricamenti mappa
- Maps SDK for iOS: ~28.000 caricamenti mappa
- Maps JavaScript API: ~28.000 caricamenti mappa

---

## 🎯 Riepilogo Comandi Rapidi

```bash
# Android SHA-1
cd android && ./gradlew signingReport

# iOS Bundle ID
grep -A1 "CFBundleIdentifier" ios/Runner/Info.plist

# Android Package Name
grep "applicationId" android/app/build.gradle.kts

# Test build Android
flutter build apk --release

# Test build iOS
flutter build ios --release

# Test Web
flutter run -d chrome --release
```

---

**🔐 Sicurezza prima di tutto! Configura le restrizioni prima del deploy in produzione.**
