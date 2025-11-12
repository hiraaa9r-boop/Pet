# MY PET CARE - Generated Assets

Icone generate durante la creazione del progetto.

---

## 🎨 Icone Categorie Professionisti

Tutte le icone sono state generate con colore brand **#0F6259** (Teal Green), stile minimale e formato PNG con sfondo trasparente.

### 1. Veterinario 🏥
**URL**: https://cdn1.genspark.ai/user-upload-image/5_generated/32fd781e-75cb-4b2d-b1b8-621ab3dd83b8.jpeg
**File name**: `veterinario.png`
**Descrizione**: Icona di stetoscopio con impronta di zampa

### 2. Toelettatore ✂️
**URL**: https://cdn1.genspark.ai/user-upload-image/5_generated/d205a0be-4ecb-478b-990f-150c0a6c3918.jpeg
**File name**: `toelettatore.png`
**Descrizione**: Forbici e pettine con impronta di zampa

### 3. Educatore/Addestratore 🎓
**URL**: https://cdn1.genspark.ai/user-upload-image/5_generated/ce3c5e26-7711-41e9-984e-4f21005eddf0.jpeg
**File name**: `educatore-addestratore.png`
**Descrizione**: Fischietto con impronta di zampa

### 4. Allevatore 🏠
**URL**: https://cdn1.genspark.ai/user-upload-image/5_generated/a1e97bea-0524-4c6d-954f-a299b5256949.jpeg
**File name**: `allevatore.png`
**Descrizione**: Casa con cuore e impronta di zampa

### 5. Pensione Pet 🏨
**URL**: https://cdn1.genspark.ai/user-upload-image/5_generated/b5755380-66dd-4ab2-b068-5e2284971655.jpeg
**File name**: `pensione-pet.png`
**Descrizione**: Edificio/casa con impronta di zampa

### 6. Taxi Pet 🚗
**URL**: https://cdn1.genspark.ai/user-upload-image/5_generated/5258a1e7-0fe8-4892-b935-141d039d261a.jpeg
**File name**: `taxi.png`
**Descrizione**: Auto con impronta di zampa

### 7. Pet Sitter 👤
**URL**: https://cdn1.genspark.ai/user-upload-image/5_generated/c48fd03c-492d-4146-83a1-4786a2aa92d0.jpeg
**File name**: `pet-sitter.png`
**Descrizione**: Silhouette persona con impronta di zampa e cuore

---

## 📱 Icona App Principale

### MY PET CARE App Icon
**URL**: https://cdn1.genspark.ai/user-upload-image/5_generated/cf409cef-cd26-4636-aa17-d4b9bfd60c8a.jpeg
**File name**: `app_icon.png`
**Descrizione**: Logo moderno con impronta di zampa e simbolo cuore, colore teal green #0F6259

---

## 📥 Come Scaricare e Posizionare

### Opzione 1: Download Manuale

1. **Apri ogni URL** nell'elenco sopra
2. **Tasto destro → Salva immagine con nome**
3. **Rinomina** con il nome file indicato
4. **Posiziona** nella directory appropriata:
   ```bash
   # Icone categorie
   mv ~/Downloads/*.png /home/user/flutter_app/assets/icons/
   
   # Icona app
   mv ~/Downloads/app_icon.png /home/user/flutter_app/assets/images/
   ```

### Opzione 2: Script Automatico

```bash
#!/bin/bash
cd /home/user/flutter_app

# Crea directory se non esistono
mkdir -p assets/icons assets/images

# Download icone categorie
curl -L "https://cdn1.genspark.ai/user-upload-image/5_generated/32fd781e-75cb-4b2d-b1b8-621ab3dd83b8.jpeg" -o assets/icons/veterinario.png
curl -L "https://cdn1.genspark.ai/user-upload-image/5_generated/d205a0be-4ecb-478b-990f-150c0a6c3918.jpeg" -o assets/icons/toelettatore.png
curl -L "https://cdn1.genspark.ai/user-upload-image/5_generated/ce3c5e26-7711-41e9-984e-4f21005eddf0.jpeg" -o assets/icons/educatore-addestratore.png
curl -L "https://cdn1.genspark.ai/user-upload-image/5_generated/a1e97bea-0524-4c6d-954f-a299b5256949.jpeg" -o assets/icons/allevatore.png
curl -L "https://cdn1.genspark.ai/user-upload-image/5_generated/b5755380-66dd-4ab2-b068-5e2284971655.jpeg" -o assets/icons/pensione-pet.png
curl -L "https://cdn1.genspark.ai/user-upload-image/5_generated/5258a1e7-0fe8-4892-b935-141d039d261a.jpeg" -o assets/icons/taxi.png
curl -L "https://cdn1.genspark.ai/user-upload-image/5_generated/c48fd03c-492d-4146-83a1-4786a2aa92d0.jpeg" -o assets/icons/pet-sitter.png

# Download icona app
curl -L "https://cdn1.genspark.ai/user-upload-image/5_generated/cf409cef-cd26-4636-aa17-d4b9bfd60c8a.jpeg" -o assets/images/app_icon.png

echo "✅ Icone scaricate con successo!"
```

**Salva script come**: `download_assets.sh`  
**Esegui**: `bash download_assets.sh`

---

## 🔧 Configurazione nell'App

### 1. Verifica pubspec.yaml

Assicurati che `pubspec.yaml` includa:

```yaml
flutter:
  assets:
    - assets/icons/
    - assets/images/
```

### 2. Utilizzo nelle Icone Mappa

Le icone sono già configurate nel modello `ProModel`:

```dart
enum ProCategory {
  veterinario,
  toelettatore,
  educatore,
  allevatore,
  pensione,
  taxi,
  petSitter,
}

extension ProCategoryExtension on ProCategory {
  String get iconPath {
    switch (this) {
      case ProCategory.veterinario:
        return 'assets/icons/veterinario.png';
      case ProCategory.toelettatore:
        return 'assets/icons/toelettatore.png';
      // ... etc
    }
  }
}
```

### 3. Uso nell'App

```dart
// Esempio: Mostra icona categoria
Image.asset(
  ProCategory.veterinario.iconPath,
  width: 48,
  height: 48,
  color: kBrandPrimary,
)
```

---

## 🎨 Personalizzazione

Se vuoi rigenerare le icone con stili diversi, usa questi prompt:

### Template Prompt Icona Categoria
```
Icon design for [CATEGORY] in pet care app. 
Simple, clean icon of [MAIN_SYMBOL] with paw print. 
Minimalist style with teal green color #0F6259 on white background. 
512x512px, PNG format, transparent background
```

### Template Prompt App Icon
```
App icon for MY PET CARE application. 
Modern, professional logo with paw print and heart symbol. 
Teal green color #0F6259 as main color with white accents. 
Clean, rounded square design suitable for mobile app icon. 
1024x1024px, high quality
```

---

## ✅ Checklist Assets

Dopo aver scaricato e posizionato:

- [ ] 7 icone categorie in `assets/icons/`
- [ ] 1 icona app in `assets/images/`
- [ ] Eseguito `flutter pub get`
- [ ] Testato visualizzazione icone nell'app
- [ ] Verificato che le icone appaiano sulla mappa

---

## 🔄 Rigenerazione Icone

Se le icone non soddisfano le aspettative, puoi:

1. **Modificare colori**: Usa editor immagini per cambiare tonalità
2. **Resize**: Usa ImageMagick o editor online
3. **Rigenerare**: Usa AI image generator con prompt sopra
4. **Sostituire**: Basta sovrascrivere i file PNG esistenti

---

**Nota**: Le icone sono state generate con AI e sono royalty-free. Puoi modificarle e usarle liberamente nel progetto MY PET CARE.
