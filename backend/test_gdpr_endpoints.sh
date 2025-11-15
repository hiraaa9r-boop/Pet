#!/bin/bash

# 🧪 Script di test per endpoint GDPR
# Testa GET /api/gdpr/me e DELETE /api/gdpr/me

set -e

# Colori per output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurazione
BACKEND_URL="${BACKEND_URL:-https://api.mypetcareapp.org}"
TEST_USER_EMAIL="test+gdpr@mypetcare.app"
TEST_USER_PASSWORD="TestGDPR123!"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Test GDPR Endpoints - MyPetCare${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Step 1: Login per ottenere token
echo -e "${YELLOW}[1/3] Login utente test...${NC}"
echo "Email: $TEST_USER_EMAIL"

# Questo è un esempio - implementa il login reale con Firebase Auth
# TOKEN=$(firebase auth:token --project=pet-care-9790d)

# Per questo test, usa un token Firebase ID valido
read -p "Inserisci Firebase ID Token per l'utente test: " TOKEN

if [ -z "$TOKEN" ]; then
  echo -e "${RED}❌ Token non fornito. Uscita.${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Token ottenuto${NC}"
echo ""

# Step 2: Test GET /api/gdpr/me (Export dati)
echo -e "${YELLOW}[2/3] Test export dati (GET /api/gdpr/me)...${NC}"

EXPORT_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X GET \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "$BACKEND_URL/api/gdpr/me")

HTTP_CODE=$(echo "$EXPORT_RESPONSE" | tail -n 1)
BODY=$(echo "$EXPORT_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 200 ]; then
  echo -e "${GREEN}✅ Export dati riuscito (HTTP $HTTP_CODE)${NC}"
  echo ""
  echo "Dati esportati:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
  echo ""
else
  echo -e "${RED}❌ Export dati fallito (HTTP $HTTP_CODE)${NC}"
  echo "Response: $BODY"
  exit 1
fi

# Step 3: Test DELETE /api/gdpr/me (Cancellazione account)
echo -e "${YELLOW}[3/3] Test cancellazione account (DELETE /api/gdpr/me)...${NC}"
echo -e "${RED}⚠️  ATTENZIONE: Questa operazione cancellerà l'account test!${NC}"
read -p "Vuoi procedere con la cancellazione? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo -e "${YELLOW}Cancellazione account saltata.${NC}"
  echo ""
  echo -e "${GREEN}======================================${NC}"
  echo -e "${GREEN}  Test completati (parziale)${NC}"
  echo -e "${GREEN}======================================${NC}"
  exit 0
fi

DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X DELETE \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "$BACKEND_URL/api/gdpr/me")

HTTP_CODE=$(echo "$DELETE_RESPONSE" | tail -n 1)
BODY=$(echo "$DELETE_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 200 ]; then
  echo -e "${GREEN}✅ Cancellazione account riuscita (HTTP $HTTP_CODE)${NC}"
  echo ""
  echo "Response:"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
  echo ""
else
  echo -e "${RED}❌ Cancellazione account fallita (HTTP $HTTP_CODE)${NC}"
  echo "Response: $BODY"
  exit 1
fi

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  ✅ Tutti i test completati${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo "Test effettuati:"
echo "  ✅ Export dati (GET /api/gdpr/me)"
echo "  ✅ Cancellazione account (DELETE /api/gdpr/me)"
