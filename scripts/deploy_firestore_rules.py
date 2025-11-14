#!/usr/bin/env python3
"""
Deploy Firestore Security Rules
My Pet Care v1.0.0
"""

import sys
import subprocess

print("=" * 60)
print("🔐 DEPLOY FIRESTORE SECURITY RULES")
print("=" * 60)

# Check if Firebase CLI is available
try:
    result = subprocess.run(['firebase', '--version'], 
                          capture_output=True, text=True, check=True)
    print(f"✅ Firebase CLI trovato: {result.stdout.strip()}")
except (subprocess.CalledProcessError, FileNotFoundError):
    print("❌ Firebase CLI non trovato!")
    print("\n📦 INSTALLAZIONE RICHIESTA:")
    print("npm install -g firebase-tools")
    print("\nOppure usa Firebase Console manualmente:")
    print("https://console.firebase.google.com/project/pet-care-9790d/firestore/rules")
    sys.exit(1)

print("\n🔄 Deploy delle regole in corso...")

try:
    # Deploy Firestore rules
    result = subprocess.run(
        ['firebase', 'deploy', '--only', 'firestore:rules', '--project', 'pet-care-9790d'],
        capture_output=True, 
        text=True,
        cwd='/home/user/flutter_app'
    )
    
    if result.returncode == 0:
        print("✅ Regole Firestore deployate con successo!")
        print(result.stdout)
    else:
        print("⚠️  Errore durante il deploy:")
        print(result.stderr)
        print("\n💡 SOLUZIONE ALTERNATIVA:")
        print("Copia manualmente le regole da firestore.rules")
        print("e incollale in Firebase Console → Firestore → Regole")
        
except Exception as e:
    print(f"❌ Errore: {e}")
    print("\n💡 Deploy manualmente le regole:")
    print("1. Apri: https://console.firebase.google.com/project/pet-care-9790d/firestore/rules")
    print("2. Copia il contenuto di firestore.rules")
    print("3. Incolla nell'editor")
    print("4. Click 'Pubblica'")

print("\n" + "=" * 60)
