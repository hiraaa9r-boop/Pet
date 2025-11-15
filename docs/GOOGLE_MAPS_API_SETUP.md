# 🗺️ Google Maps API - Configurazione Completa

Guida completa per configurare Google Maps API su Android, iOS e Web.

---

## 📋 Prerequisiti

1. **Google Cloud Console Account**
   - Vai su: https://console.cloud.google.com/
   - Crea un progetto o seleziona uno esistente

2. **Abilita API necessarie:**
   - Maps SDK for Android
   - Maps SDK for iOS
   - Maps JavaScript API
   - Geolocation API (opzionale ma raccomandato)
   - Places API (per ricerche avanzate - opzionale)

---

## 🔧 STEP 1: Crea API Key su Google Cloud Console

### 1.1 Crea una nuova API Key

```bash
# Naviga su:
Google Cloud Console → API e servizi → Credenziali → Crea credenziali → Chiave API
```

### 1.2 Limita la chiave (IMPORTANTE per sicurezza)

**Crea 3 chiavi separate per maggiore sicurezza:**

#### A) **Android API Key**
- **Restrizioni applicazione:** App Android
- **Aggiungi pacchetto:** `com.spark.orange` (il tuo package name)
- **Aggiungi firma SHA-1:**
  ```bash
  # Debug keystore
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  
  # Release keystore
  keytool -list -v -keystore android/release-key.jks -alias release
  ```

#### B) **iOS API Key**
- **Restrizioni applicazione:** App iOS
- **Aggiungi Bundle ID:** `com.example.myPetCare` (il tuo bundle ID)

#### C) **Web API Key**
- **Restrizioni applicazione:** Referrer HTTP
- **Aggiungi referrer:**
  ```
  https://pet-care-9790d.web.app/*
  https://pet-care-9790d.firebaseapp.com/*
  http://localhost:*/*
  ```

### 1.3 Abilita API per ogni chiave

Per tutte e 3 le chiavi:
- ✅ Maps SDK for Android (solo per Android key)
- ✅ Maps SDK for iOS (solo per iOS key)
- ✅ Maps JavaScript API (solo per Web key)
- ✅ Geolocation API (tutte)
- ✅ Places API (opzionale)

---

## 📱 STEP 2: Configurazione Android

### 2.1 AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permessi Google Maps -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />

    <application ...>
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_ANDROID_API_KEY_HERE" />
    </application>
</manifest>
```

### 2.2 Verifica Package Name

**File:** `android/app/build.gradle.kts`

```kotlin
android {
    defaultConfig {
        applicationId = "com.spark.orange" // Deve corrispondere a Google Cloud Console
    }
}
```

### 2.3 Test su Dispositivo Android

```bash
# Build e installa APK
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk

# Verifica logs
adb logcat | grep -i "maps"
```

---

## 🍎 STEP 3: Configurazione iOS

### 3.1 AppDelegate.swift

File: `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API Key
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3.2 Info.plist

File: `ios/Runner/Info.plist`

```xml
<dict>
    <!-- Permessi localizzazione -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>MyPetCare ha bisogno della tua posizione per mostrare i professionisti vicino a te.</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>MyPetCare utilizza la tua posizione per offrirti servizi personalizzati.</string>
</dict>
```

### 3.3 Podfile

File: `ios/Podfile`

Aggiungi questa riga se non presente:

```ruby
platform :ios, '14.0'  # Google Maps richiede iOS 14.0+
```

### 3.4 Install Pods

```bash
cd ios
pod install
cd ..
```

---

## 🌐 STEP 4: Configurazione Web

### 4.1 index.html

File: `web/index.html`

Aggiungi PRIMA del tag `<body>`:

```html
<!DOCTYPE html>
<html>
<head>
  <!-- ... altri meta tag ... -->
  
  <!-- Google Maps JavaScript API -->
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_API_KEY_HERE"></script>
</head>
<body>
  <!-- Flutter app -->
</body>
</html>
```

### 4.2 Test Web Locale

```bash
# Build web
flutter build web --release

# Serve localmente
python3 -m http.server 5060 --directory build/web --bind 0.0.0.0

# Apri browser
open http://localhost:5060
```

---

## 🔑 STEP 5: Gestione Sicura delle Chiavi

### 5.1 Variabili d'Ambiente (Raccomandato)

**NON committare le chiavi API in Git!**

#### Opzione A: .env file (Development)

File: `.env` (aggiunto a .gitignore)

```bash
GOOGLE_MAPS_ANDROID_KEY=AIza...
GOOGLE_MAPS_IOS_KEY=AIza...
GOOGLE_MAPS_WEB_KEY=AIza...
```

#### Opzione B: Script di build

File: `scripts/set_api_keys.sh`

```bash
#!/bin/bash

# Leggi chiavi da variabili d'ambiente
ANDROID_KEY="${GOOGLE_MAPS_ANDROID_KEY}"
IOS_KEY="${GOOGLE_MAPS_IOS_KEY}"
WEB_KEY="${GOOGLE_MAPS_WEB_KEY}"

# Android
sed -i '' "s/YOUR_ANDROID_API_KEY_HERE/$ANDROID_KEY/g" android/app/src/main/AndroidManifest.xml

# iOS
sed -i '' "s/YOUR_IOS_API_KEY_HERE/$IOS_KEY/g" ios/Runner/AppDelegate.swift

# Web
sed -i '' "s/YOUR_WEB_API_KEY_HERE/$WEB_KEY/g" web/index.html

echo "✅ API Keys configurate"
```

Usa:
```bash
export GOOGLE_MAPS_ANDROID_KEY="AIza..."
export GOOGLE_MAPS_IOS_KEY="AIza..."
export GOOGLE_MAPS_WEB_KEY="AIza..."
bash scripts/set_api_keys.sh
```

---

## 🧪 STEP 6: Test Funzionalità

### 6.1 Checklist Test Android

- [ ] Mappa si carica correttamente
- [ ] Marker vengono visualizzati
- [ ] Geolocalizzazione funziona
- [ ] Info window si aprono al tap
- [ ] Filtri funzionano
- [ ] Nessun errore nei logs

### 6.2 Checklist Test iOS

- [ ] Mappa si carica correttamente
- [ ] Permessi localizzazione richiesti
- [ ] Marker visualizzati
- [ ] Animazioni smooth
- [ ] Info window funzionanti

### 6.3 Checklist Test Web

- [ ] Mappa si carica in Chrome
- [ ] Mappa si carica in Firefox
- [ ] Mappa si carica in Safari
- [ ] Controlli mappa funzionanti
- [ ] Nessun errore in console

---

## 🚨 Troubleshooting Comuni

### ❌ "Map failed to load: Google Maps JavaScript API error: RefererNotAllowedMapError"

**Soluzione:**
1. Vai su Google Cloud Console → API Key → Web Key
2. Aggiungi referrer corretto:
   - `http://localhost:*/*`
   - `https://your-domain.web.app/*`

### ❌ "Map failed to load: Google Maps SDK for Android returned: INVALID_API_KEY"

**Soluzione:**
1. Verifica SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
   ```
2. Aggiungi SHA-1 su Google Cloud Console
3. Verifica package name corrisponda

### ❌ "Marker non si vedono su mappa"

**Soluzione:**
```dart
// Verifica che i PRO abbiano latitude e longitude non nulli
final pros = snapshot.docs
    .map((doc) => ProModel.fromFirestore(doc.data(), doc.id))
    .where((pro) => pro.latitude != null && pro.longitude != null)
    .toList();
```

### ❌ "Permessi localizzazione negati"

**Android:**
```xml
<!-- Aggiungi in AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS:**
```xml
<!-- Aggiungi in Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Descrizione chiara dell'uso</string>
```

---

## 📊 Monitoraggio Utilizzo API

### 6.1 Controlla Quote e Costi

**Dashboard:** https://console.cloud.google.com/apis/dashboard

- Maps SDK for Android: Gratuito fino a unlimited richieste
- Maps SDK for iOS: Gratuito fino a unlimited richieste  
- Maps JavaScript API: $7/1000 richieste (dopo free tier)

**Free Tier mensile:**
- 28,000 mappe dinamiche caricate
- 100,000 mappe statiche
- $200 crediti Google Cloud

### 6.2 Alert su Superamento Quote

```bash
# Imposta alert su:
Google Cloud Console → Billing → Budget e avvisi → Crea budget
```

---

## ✅ Configurazione Completa - Checklist Finale

- [ ] API Keys create su Google Cloud Console
- [ ] API abilitate (Maps SDK Android, iOS, JavaScript)
- [ ] Chiavi Android configurate con SHA-1
- [ ] Chiavi iOS configurate con Bundle ID
- [ ] Chiavi Web configurate con referrer
- [ ] AndroidManifest.xml aggiornato
- [ ] AppDelegate.swift aggiornato (iOS)
- [ ] index.html aggiornato (Web)
- [ ] Permessi localizzazione aggiunti
- [ ] Test su Android ✓
- [ ] Test su iOS ✓
- [ ] Test su Web ✓
- [ ] Chiavi API NON committate su Git
- [ ] Alert billing configurati

---

## 🔗 Link Utili

- **Google Maps Platform:** https://developers.google.com/maps
- **Flutter Google Maps Plugin:** https://pub.dev/packages/google_maps_flutter
- **API Key Best Practices:** https://developers.google.com/maps/api-security-best-practices
- **Pricing Calculator:** https://mapsplatform.google.com/pricing/

---

**Ultima revisione:** 15 Novembre 2024  
**Progetto:** MY PET CARE  
**Package Android:** com.spark.orange
