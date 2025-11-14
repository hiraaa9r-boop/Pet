#!/usr/bin/env python3
"""Check Firebase Database Configuration"""

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.services.firestore_admin import FirestoreAdminClient

print("🔍 Verifico configurazione database Firebase...")

# Initialize
try:
    cred = credentials.Certificate('/opt/flutter/firebase-admin-sdk.json')
    try:
        firebase_admin.get_app()
    except ValueError:
        firebase_admin.initialize_app(cred)
    
    # Try to list databases
    print("\n📊 Database disponibili nel progetto:")
    
    # Use Firestore Admin API
    admin_client = FirestoreAdminClient()
    parent = "projects/pet-care-9790d"
    
    try:
        databases = admin_client.list_databases(parent=parent)
        for db in databases:
            print(f"   ✅ Database trovato: {db.name}")
            print(f"      Location: {db.location_id}")
            print(f"      Type: {db.type_.name}")
    except Exception as e:
        print(f"   ⚠️  Errore listing databases: {e}")
    
    # Try default database
    print("\n🧪 Test connessione database default:")
    db = firestore.client()
    
    # Try to create a test document
    test_ref = db.collection('_test').document('connection_test')
    test_ref.set({
        'timestamp': firestore.SERVER_TIMESTAMP,
        'message': 'Firebase connection test'
    })
    print("   ✅ Scrittura test riuscita!")
    
    # Read it back
    doc = test_ref.get()
    if doc.exists:
        print(f"   ✅ Lettura test riuscita: {doc.to_dict()}")
    
    # Delete test document
    test_ref.delete()
    print("   ✅ Database Firestore funzionante!")
    
except Exception as e:
    print(f"❌ Errore: {e}")
    print("\n💡 Possibili cause:")
    print("   1. Database non ancora propagato (attendi 1-2 minuti)")
    print("   2. Database creato con ID diverso da 'default'")
    print("   3. Permessi Admin SDK insufficienti")
