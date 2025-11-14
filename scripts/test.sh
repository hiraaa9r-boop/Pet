#!/bin/bash

# 🧪 MyPetCare - Full System Test Runner
# Wrapper script per eseguire test completo del sistema

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "🧪 MyPetCare - Full System Test"
echo "=========================================="
echo ""

# Verifica dipendenze
echo "🔍 Verifica dipendenze..."

if ! command -v npx &> /dev/null; then
  echo -e "${RED}❌ ERRORE: npx non trovato${NC}"
  echo "Installare Node.js >= 18"
  exit 1
fi

if ! command -v ts-node &> /dev/null; then
  echo -e "${YELLOW}⚠️  ts-node non trovato, installo...${NC}"
  npm install -g ts-node typescript
fi

echo -e "${GREEN}✅ Dipendenze ok${NC}"
echo ""

# Navigazione directory
cd "$(dirname "$0")/backend"

echo "📁 Directory: $(pwd)"
echo ""

# Installazione dipendenze se necessario
if [ ! -d "node_modules" ]; then
  echo "📦 Installazione dipendenze npm..."
  npm install
  echo ""
fi

# Verifica Firebase credentials
if [ ! -f "keys/firebase-key.json" ] && [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
  echo -e "${RED}❌ ERRORE: Firebase credentials non trovate${NC}"
  echo ""
  echo "Soluzioni:"
  echo "1. Crea directory keys/ e aggiungi firebase-key.json"
  echo "2. Oppure imposta: export GOOGLE_APPLICATION_CREDENTIALS=path/to/key.json"
  echo ""
  exit 1
fi

echo -e "${GREEN}✅ Firebase credentials configurate${NC}"
echo ""

# Esecuzione test
echo "🚀 Avvio test completo sistema..."
echo ""
echo "=========================================="
echo ""

npx ts-node --esm scripts/test_full_system.ts

EXIT_CODE=$?

echo ""
echo "=========================================="

if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}✅ Test completato con successo!${NC}"
  echo ""
  
  # Mostra prossimi step
  echo -e "${BLUE}📋 Prossimi step per validazione completa:${NC}"
  echo ""
  
  echo "1️⃣ Test Endpoint Reminder (richiede backend deployato):"
  echo "   export API_BASE=\"https://your-backend.run.app\""
  echo "   export CRON_SECRET=\"your-secret\""
  echo '   curl -X POST "$API_BASE/jobs/send-reminders" -H "X-Cron-Secret: $CRON_SECRET"'
  echo ""
  
  echo "2️⃣ Verifica Admin Stats:"
  echo "   export ADMIN_TOKEN=\"your-firebase-admin-token\""
  echo '   curl -H "Authorization: Bearer $ADMIN_TOKEN" "$API_BASE/admin/stats" | jq'
  echo ""
  
  echo "3️⃣ Test Admin Stats automatico:"
  echo "   bash test_admin_stats.sh"
  echo ""
  
  echo "4️⃣ Verifica Dashboard Flutter:"
  echo "   - Apri app web (https://mypetcare.web.app)"
  echo "   - Login come admin"
  echo "   - Naviga a /admin/analytics"
  echo "   - Verifica grafico 30 giorni popolato"
  echo ""
  
else
  echo -e "${RED}❌ Test fallito con exit code $EXIT_CODE${NC}"
  echo ""
  echo "Controlla i log sopra per dettagli errore"
  echo ""
fi

exit $EXIT_CODE
