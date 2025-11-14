#!/usr/bin/env python3
"""
Verifica corrispondenza SHA-1 tra keystore e google-services.json
"""

import json
import subprocess
import sys

def get_keystore_sha1():
    """Recupera SHA-1 dal keystore release"""
    try:
        result = subprocess.run(
            ['keytool', '-list', '-v', '-keystore', 'android/release-key.jks', 
             '-alias', 'release', '-storepass', 'android123'],
            capture_output=True,
            text=True
        )
        
        for line in result.stdout.split('\n'):
            if 'SHA1:' in line:
                sha1 = line.split('SHA1:')[1].strip()
                # Rimuovi ":" e converti in minuscolo
                return sha1.replace(':', '').lower()
    except Exception as e:
        print(f"❌ Errore lettura keystore: {e}")
        return None

def get_google_services_sha1():
    """Recupera SHA-1 da google-services.json"""
    try:
        with open('android/app/google-services.json', 'r') as f:
            data = json.load(f)
        
        sha1_list = []
        for client in data.get('client', []):
            for oauth in client.get('oauth_client', []):
                if 'android_info' in oauth and 'certificate_hash' in oauth['android_info']:
                    sha1_list.append(oauth['android_info']['certificate_hash'])
        
        return sha1_list
    except Exception as e:
        print(f"❌ Errore lettura google-services.json: {e}")
        return []

def main():
    print("🔍 VERIFICA FIREBASE SHA-1 CONFIGURATION")
    print("=" * 60)
    
    # Ottieni SHA-1 keystore
    keystore_sha1 = get_keystore_sha1()
    if not keystore_sha1:
        print("\n❌ Impossibile recuperare SHA-1 dal keystore!")
        sys.exit(1)
    
    print(f"\n✅ SHA-1 Keystore Release:")
    print(f"   {keystore_sha1}")
    
    # Ottieni SHA-1 da google-services.json
    google_sha1_list = get_google_services_sha1()
    if not google_sha1_list:
        print("\n❌ Nessun SHA-1 trovato in google-services.json!")
        sys.exit(1)
    
    print(f"\n📄 SHA-1 in google-services.json:")
    for sha in google_sha1_list:
        print(f"   {sha}")
    
    # Verifica corrispondenza
    print("\n" + "=" * 60)
    if keystore_sha1 in google_sha1_list:
        print("✅ MATCH! Il keystore è registrato su Firebase.")
        print("   L'app dovrebbe funzionare correttamente.")
        sys.exit(0)
    else:
        print("❌ MISMATCH! Il keystore NON è registrato su Firebase!")
        print("\n⚠️  AZIONE RICHIESTA:")
        print("   1. Vai su Firebase Console:")
        print("      https://console.firebase.google.com/project/pet-care-9790d/settings/general/")
        print("\n   2. Aggiungi questa impronta SHA-1:")
        print(f"      {keystore_sha1.upper()}")
        print("\n   3. Formato con ':' per Firebase Console:")
        sha1_formatted = ':'.join([keystore_sha1[i:i+2] for i in range(0, len(keystore_sha1), 2)]).upper()
        print(f"      {sha1_formatted}")
        print("\n   4. Dopo aver aggiunto, scarica il nuovo google-services.json")
        print("      e sostituiscilo in: android/app/google-services.json")
        print("\n   5. Rebuild: flutter clean && flutter build apk --release")
        sys.exit(1)

if __name__ == '__main__':
    main()
