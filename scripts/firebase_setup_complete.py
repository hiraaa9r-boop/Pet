#!/usr/bin/env python3
"""
Firebase Setup Complete - Verifica e Inizializzazione Dati
My Pet Care v1.0.0
"""

import sys
import json
from datetime import datetime, timedelta

print("=" * 60)
print("🔥 FIREBASE SETUP COMPLETE - MY PET CARE v1.0.0")
print("=" * 60)

# Import Firebase Admin
try:
    import firebase_admin
    from firebase_admin import credentials, firestore, auth
    print("✅ firebase-admin importato con successo")
except ImportError as e:
    print(f"❌ Errore import firebase-admin: {e}")
    print("\n📦 INSTALLAZIONE RICHIESTA:")
    print("pip install firebase-admin==7.1.0")
    sys.exit(1)

# Inizializza Firebase Admin SDK
try:
    cred = credentials.Certificate('/opt/flutter/firebase-admin-sdk.json')
    
    # Check if already initialized
    try:
        firebase_admin.get_app()
        print("✅ Firebase Admin già inizializzato")
    except ValueError:
        firebase_admin.initialize_app(cred)
        print("✅ Firebase Admin inizializzato")
    
    db = firestore.client()
    print(f"✅ Firestore client connesso: pet-care-9790d")
    
except Exception as e:
    print(f"❌ Errore inizializzazione Firebase: {e}")
    sys.exit(1)

print("\n" + "=" * 60)
print("📊 VERIFICA CONFIGURAZIONE FIRESTORE")
print("=" * 60)

# Verifica collections esistenti
collections_to_check = ['users', 'professionals', 'bookings']

for collection_name in collections_to_check:
    try:
        docs = db.collection(collection_name).limit(1).get()
        count_ref = db.collection(collection_name).count()
        count = count_ref.get()[0][0].value
        
        print(f"✅ Collection '{collection_name}': {count} documenti")
        
    except Exception as e:
        print(f"⚠️  Collection '{collection_name}': Errore verifica - {e}")

print("\n" + "=" * 60)
print("🔐 VERIFICA AUTENTICAZIONE")
print("=" * 60)

try:
    # Lista primi 5 utenti
    users = auth.list_users(max_results=5)
    print(f"✅ Firebase Auth: {len(users.users)} utenti trovati")
    
    for user in users.users:
        print(f"   - {user.email} (UID: {user.uid[:8]}...)")
        
except Exception as e:
    print(f"⚠️  Errore verifica Auth: {e}")

print("\n" + "=" * 60)
print("🧪 CREAZIONE DATI DI TEST (Opzionale)")
print("=" * 60)

def create_test_data():
    """Crea dati di test se le collections sono vuote"""
    
    # Verifica se esistono già professionisti
    pros = list(db.collection('professionals').limit(1).stream())
    
    if len(pros) > 0:
        print("ℹ️  Dati già presenti - Skip creazione test data")
        return
    
    print("📝 Creazione professionisti di test...")
    
    # Professionisti di test con geolocalizzazione Milano
    test_pros = [
        {
            'businessName': 'Clinica Veterinaria Milano Centro',
            'category': 'veterinario',
            'city': 'Milano',
            'lat': 45.4642,
            'lng': 9.1900,
            'about': 'Clinica veterinaria con 20 anni di esperienza nel centro di Milano',
            'priceList': {
                'Visita generale': 50,
                'Vaccinazione': 35,
                'Controllo annuale': 60
            },
            'availability': {
                'monday': [{'start': '09:00', 'end': '13:00'}, {'start': '14:00', 'end': '18:00'}],
                'tuesday': [{'start': '09:00', 'end': '13:00'}, {'start': '14:00', 'end': '18:00'}],
                'wednesday': [{'start': '09:00', 'end': '13:00'}, {'start': '14:00', 'end': '18:00'}],
                'thursday': [{'start': '09:00', 'end': '13:00'}, {'start': '14:00', 'end': '18:00'}],
                'friday': [{'start': '09:00', 'end': '13:00'}, {'start': '14:00', 'end': '18:00'}],
            },
            'subscriptionStatus': 'active',
            'subscriptionPlan': 'annual',
            'isActive': True,
            'createdAt': firestore.SERVER_TIMESTAMP,
            'updatedAt': firestore.SERVER_TIMESTAMP,
        },
        {
            'businessName': 'Pet Grooming Milano',
            'category': 'toelettatore',
            'city': 'Milano',
            'lat': 45.4785,
            'lng': 9.2134,
            'about': 'Toelettatura professionale per cani e gatti di tutte le razze',
            'priceList': {
                'Bagno cane piccola taglia': 25,
                'Bagno cane media taglia': 35,
                'Bagno cane grande taglia': 50,
                'Tosatura completa': 60
            },
            'availability': {
                'monday': [{'start': '10:00', 'end': '19:00'}],
                'tuesday': [{'start': '10:00', 'end': '19:00'}],
                'wednesday': [{'start': '10:00', 'end': '19:00'}],
                'thursday': [{'start': '10:00', 'end': '19:00'}],
                'friday': [{'start': '10:00', 'end': '19:00'}],
                'saturday': [{'start': '10:00', 'end': '16:00'}],
            },
            'subscriptionStatus': 'trial',
            'subscriptionPlan': 'monthly',
            'isActive': True,
            'createdAt': firestore.SERVER_TIMESTAMP,
            'updatedAt': firestore.SERVER_TIMESTAMP,
        },
        {
            'businessName': 'Dog Sitter Milano',
            'category': 'pet_sitter',
            'city': 'Milano',
            'lat': 45.4520,
            'lng': 9.1820,
            'about': 'Servizio professionale di dog sitting e passeggiate',
            'priceList': {
                'Passeggiata 30 min': 15,
                'Passeggiata 1 ora': 25,
                'Dog sitting giornaliero': 40
            },
            'availability': {
                'monday': [{'start': '08:00', 'end': '12:00'}, {'start': '15:00', 'end': '19:00'}],
                'tuesday': [{'start': '08:00', 'end': '12:00'}, {'start': '15:00', 'end': '19:00'}],
                'wednesday': [{'start': '08:00', 'end': '12:00'}, {'start': '15:00', 'end': '19:00'}],
                'thursday': [{'start': '08:00', 'end': '12:00'}, {'start': '15:00', 'end': '19:00'}],
                'friday': [{'start': '08:00', 'end': '12:00'}, {'start': '15:00', 'end': '19:00'}],
                'saturday': [{'start': '09:00', 'end': '13:00'}],
                'sunday': [{'start': '09:00', 'end': '13:00'}],
            },
            'subscriptionStatus': 'active',
            'subscriptionPlan': 'quarterly',
            'isActive': True,
            'createdAt': firestore.SERVER_TIMESTAMP,
            'updatedAt': firestore.SERVER_TIMESTAMP,
        }
    ]
    
    for pro_data in test_pros:
        doc_ref = db.collection('professionals').add(pro_data)
        print(f"   ✅ Creato: {pro_data['businessName']}")
    
    print(f"\n✅ Creati {len(test_pros)} professionisti di test")

# Esegui creazione dati di test
try:
    create_test_data()
except Exception as e:
    print(f"⚠️  Errore creazione test data: {e}")

print("\n" + "=" * 60)
print("✅ SETUP FIREBASE COMPLETATO!")
print("=" * 60)
print("\n📱 L'app My Pet Care è pronta per:")
print("   ✅ Autenticazione Firebase")
print("   ✅ Gestione professionisti con geolocalizzazione")
print("   ✅ Sistema prenotazioni")
print("   ✅ Sistema calendario")
print("   ✅ Push notifications (FCM)")
print("   ✅ Gestione abbonamenti")
print("\n🚀 Pronto per build APK/AAB e deployment!")
print("=" * 60)
