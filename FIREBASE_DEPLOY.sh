#!/bin/bash
# Firebase Hosting Deploy Script
# Progetto: My Pet Care (pet-care-9790d)
# Data: 15 Novembre 2024

set -e

echo "🚀 Firebase Hosting Deploy - My Pet Care"
echo "========================================="
echo ""

# Verifica prerequisiti
echo "📋 Verifica prerequisiti..."

# Check Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI non trovato!"
    echo "   Installa con: npm install -g firebase-tools"
    exit 1
fi
echo "✅ Firebase CLI trovato: $(firebase --version)"

# Check Firebase login
if ! firebase projects:list &> /dev/null; then
    echo "⚠️  Non sei autenticato!"
    echo "   Esegui: firebase login"
    exit 1
fi
echo "✅ Autenticazione Firebase OK"

# Verifica file
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml non trovato!"
    echo "   Esegui questo script dalla root del progetto Flutter"
    exit 1
fi
echo "✅ Root progetto verificata"

if [ ! -f "firebase.json" ]; then
    echo "❌ firebase.json non trovato!"
    exit 1
fi
echo "✅ firebase.json trovato"

echo ""
echo "🔨 Build Flutter Web..."
echo "======================="

# Clean previous build
echo "Pulizia build precedente..."
flutter clean

# Get dependencies
echo "Download dipendenze..."
flutter pub get

# Build for web
echo "Build in corso (questo può richiedere 1-2 minuti)..."
flutter build web --release \
  --dart-define=flutter.inspector.structuredErrors=false \
  --dart-define=debugShowCheckedModeBanner=false

if [ ! -d "build/web" ]; then
    echo "❌ Build fallita!"
    exit 1
fi
echo "✅ Build completata!"

echo ""
echo "📊 Dimensioni build:"
du -sh build/web/

echo ""
echo "🚀 Deploy su Firebase Hosting..."
echo "================================"

firebase deploy --only hosting --project pet-care-9790d

echo ""
echo "================================"
echo "✅ DEPLOY COMPLETATO!"
echo "================================"
echo ""
echo "🔗 App disponibile su:"
echo "   https://pet-care-9790d.web.app"
echo "   https://pet-care-9790d.firebaseapp.com"
echo ""
echo "📊 Per vedere le statistiche:"
echo "   https://console.firebase.google.com/project/pet-care-9790d/hosting"
echo ""
