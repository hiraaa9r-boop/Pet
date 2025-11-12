#!/bin/bash

# 🧪 Test Script per /admin/stats endpoint
# Verifica la struttura della risposta e la serie giornaliera

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "🧪 MyPetCare - Admin Stats API Test"
echo "=========================================="
echo ""

# Configurazione
API_BASE="${API_BASE:-https://api.mypetcare.app}"
ADMIN_TOKEN="${ADMIN_TOKEN:-}"

if [ -z "$ADMIN_TOKEN" ]; then
  echo -e "${RED}❌ ERRORE: ADMIN_TOKEN non configurato${NC}"
  echo ""
  echo "Usage:"
  echo "  export ADMIN_TOKEN=\"your-firebase-admin-id-token\""
  echo "  export API_BASE=\"https://your-backend-url.run.app\"  # opzionale"
  echo "  bash test_admin_stats.sh"
  echo ""
  exit 1
fi

echo "🔗 API Base: $API_BASE"
echo "🔑 Token: ${ADMIN_TOKEN:0:20}..."
echo ""

# Endpoint
ENDPOINT="$API_BASE/admin/stats"

echo "📡 Testing GET $ENDPOINT"
echo ""

# Esegui richiesta
RESPONSE=$(curl -sS -H "Authorization: Bearer $ADMIN_TOKEN" "$ENDPOINT")

# Check HTTP status (se curl ritorna errore)
if [ $? -ne 0 ]; then
  echo -e "${RED}❌ ERRORE: Richiesta HTTP fallita${NC}"
  exit 1
fi

# Verifica se risposta è JSON valido
if ! echo "$RESPONSE" | jq . > /dev/null 2>&1; then
  echo -e "${RED}❌ ERRORE: Risposta non è JSON valido${NC}"
  echo "Risposta raw:"
  echo "$RESPONSE"
  exit 1
fi

echo -e "${GREEN}✅ Risposta ricevuta${NC}"
echo ""

# Estrai campi principali
USERS_TOTAL=$(echo "$RESPONSE" | jq -r '.usersTotal // "N/A"')
ACTIVE_PROS=$(echo "$RESPONSE" | jq -r '.activePros // "N/A"')
REVENUE_30D=$(echo "$RESPONSE" | jq -r '.revenue30d // "N/A"')
BOOKINGS_30D=$(echo "$RESPONSE" | jq -r '.bookings30d // "N/A"')

echo "📊 Statistiche Generali:"
echo "   Utenti totali:       $USERS_TOTAL"
echo "   PRO attivi:          $ACTIVE_PROS"
echo "   Entrate (30g):       €$REVENUE_30D"
echo "   Prenotazioni (30g):  $BOOKINGS_30D"
echo ""

# Verifica revenueSeries
HAS_SERIES=$(echo "$RESPONSE" | jq -r 'has("revenueSeries")')

if [ "$HAS_SERIES" != "true" ]; then
  echo -e "${RED}❌ ERRORE: Campo 'revenueSeries' mancante${NC}"
  echo "Struttura risposta:"
  echo "$RESPONSE" | jq 'keys'
  exit 1
fi

echo -e "${GREEN}✅ Campo 'revenueSeries' presente${NC}"

# Estrai serie
DAYS_COUNT=$(echo "$RESPONSE" | jq '.revenueSeries.days | length')
VALUES_COUNT=$(echo "$RESPONSE" | jq '.revenueSeries.values | length')

echo ""
echo "📈 Serie Giornaliera Entrate:"
echo "   Giorni array:  $DAYS_COUNT elementi"
echo "   Valori array:  $VALUES_COUNT elementi"

# Verifica lunghezza array
if [ "$DAYS_COUNT" -ne 30 ]; then
  echo -e "${YELLOW}⚠️  WARNING: Attesi 30 giorni, trovati $DAYS_COUNT${NC}"
else
  echo -e "${GREEN}✅ Lunghezza array corretta (30 giorni)${NC}"
fi

if [ "$DAYS_COUNT" -ne "$VALUES_COUNT" ]; then
  echo -e "${RED}❌ ERRORE: Mismatch lunghezza array (days: $DAYS_COUNT, values: $VALUES_COUNT)${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Lunghezze array coincidono${NC}"
echo ""

# Mostra primi e ultimi 3 giorni
echo "🗓️  Primi 3 giorni:"
echo "$RESPONSE" | jq -r '.revenueSeries | 
  .days[0:3] as $d | 
  .values[0:3] as $v | 
  [range(3)] | 
  map("   \($d[.]):  €\($v[.])")[]'

echo ""
echo "🗓️  Ultimi 3 giorni:"
echo "$RESPONSE" | jq -r '.revenueSeries | 
  .days[-3:] as $d | 
  .values[-3:] as $v | 
  [range(3)] | 
  map("   \($d[.]):  €\($v[.])")[]'

echo ""

# Calcola statistiche serie
TOTAL_REVENUE=$(echo "$RESPONSE" | jq '[.revenueSeries.values[]] | add')
MAX_DAY_REVENUE=$(echo "$RESPONSE" | jq '[.revenueSeries.values[]] | max')
AVG_DAY_REVENUE=$(echo "$RESPONSE" | jq '[.revenueSeries.values[]] | add / length')
DAYS_WITH_REVENUE=$(echo "$RESPONSE" | jq '[.revenueSeries.values[]] | map(select(. > 0)) | length')

echo "📊 Statistiche Serie:"
echo "   Totale entrate:       €$TOTAL_REVENUE"
echo "   Max giornaliero:      €$MAX_DAY_REVENUE"
echo "   Media giornaliera:    €$(printf "%.2f" $AVG_DAY_REVENUE)"
echo "   Giorni con entrate:   $DAYS_WITH_REVENUE/30"
echo ""

# Verifica formato date (YYYY-MM-DD)
FIRST_DAY=$(echo "$RESPONSE" | jq -r '.revenueSeries.days[0]')
if [[ ! "$FIRST_DAY" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo -e "${RED}❌ ERRORE: Formato data non valido: $FIRST_DAY${NC}"
  echo "   Atteso: YYYY-MM-DD"
  exit 1
fi
echo -e "${GREEN}✅ Formato date corretto (YYYY-MM-DD)${NC}"

# Verifica ordine cronologico
LAST_DAY=$(echo "$RESPONSE" | jq -r '.revenueSeries.days[-1]')
if [[ "$FIRST_DAY" > "$LAST_DAY" ]]; then
  echo -e "${RED}❌ ERRORE: Array non ordinato cronologicamente${NC}"
  echo "   Primo giorno: $FIRST_DAY"
  echo "   Ultimo giorno: $LAST_DAY"
  exit 1
fi
echo -e "${GREEN}✅ Array ordinato cronologicamente${NC}"
echo ""

# Calcola range date atteso
TODAY=$(date -u +%Y-%m-%d)
EXPECTED_LAST=$(date -u +%Y-%m-%d)
EXPECTED_FIRST=$(date -u -d "29 days ago" +%Y-%m-%d 2>/dev/null || date -u -v-29d +%Y-%m-%d)

echo "📅 Range Date:"
echo "   Atteso primo:  $EXPECTED_FIRST"
echo "   Atteso ultimo: $EXPECTED_LAST"
echo "   Effettivo primo:  $FIRST_DAY"
echo "   Effettivo ultimo: $LAST_DAY"

if [ "$LAST_DAY" != "$EXPECTED_LAST" ]; then
  echo -e "${YELLOW}⚠️  WARNING: Ultimo giorno diverso da oggi${NC}"
  echo "   (Potrebbe essere corretto se server in timezone diverso)"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Test completato con successo!${NC}"
echo "=========================================="
echo ""

# Opzionale: salva risposta completa per debug
if [ "${SAVE_RESPONSE}" = "true" ]; then
  OUTPUT_FILE="admin_stats_response_$(date +%Y%m%d_%H%M%S).json"
  echo "$RESPONSE" | jq . > "$OUTPUT_FILE"
  echo "💾 Risposta completa salvata in: $OUTPUT_FILE"
  echo ""
fi

# Mostra JSON completo formattato (se richiesto)
if [ "${SHOW_FULL}" = "true" ]; then
  echo "📄 Risposta JSON completa:"
  echo "$RESPONSE" | jq .
fi

exit 0
