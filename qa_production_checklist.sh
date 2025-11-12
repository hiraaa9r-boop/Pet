#!/bin/bash

# 🧪 MyPetCare - Production QA Checklist
# Automated validation of production deployment

set -e

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "🧪 MyPetCare - Production QA Checklist"
echo "=========================================="
echo ""

# Configuration
BACKEND_URL="${BACKEND_URL:-}"
ADMIN_TOKEN="${ADMIN_TOKEN:-}"
CRON_SECRET="${CRON_SECRET:-}"

# Prompt for missing config
if [ -z "$BACKEND_URL" ]; then
  read -p "Backend URL (es: https://mypetcare-backend-xxx.run.app): " BACKEND_URL
fi

if [ -z "$ADMIN_TOKEN" ]; then
  echo -e "${YELLOW}⚠️  ADMIN_TOKEN non configurato${NC}"
  echo "Alcuni test verranno skippati"
  echo ""
fi

if [ -z "$CRON_SECRET" ]; then
  echo -e "${YELLOW}⚠️  CRON_SECRET non configurato${NC}"
  echo "Test CRON jobs verranno skippati"
  echo ""
fi

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test result function
test_result() {
  local test_name="$1"
  local result="$2"
  local details="$3"
  
  if [ "$result" == "pass" ]; then
    echo -e "${GREEN}✅ $test_name${NC}"
    [ -n "$details" ] && echo "   $details"
    ((TESTS_PASSED++))
  elif [ "$result" == "fail" ]; then
    echo -e "${RED}❌ $test_name${NC}"
    [ -n "$details" ] && echo "   $details"
    ((TESTS_FAILED++))
  else
    echo -e "${YELLOW}⏭️  $test_name (skipped)${NC}"
    [ -n "$details" ] && echo "   $details"
    ((TESTS_SKIPPED++))
  fi
  echo ""
}

# ==========================================
# Test 1: Backend Health Check
# ==========================================

echo "🏥 Test 1: Backend Health Check"
HEALTH_RESPONSE=$(curl -s "$BACKEND_URL/health" 2>/dev/null || echo "")
HEALTH_STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.status' 2>/dev/null || echo "error")

if [ "$HEALTH_STATUS" == "healthy" ]; then
  test_result "Backend Health" "pass" "Status: $HEALTH_STATUS"
else
  test_result "Backend Health" "fail" "Expected: healthy, Got: $HEALTH_STATUS"
fi

# ==========================================
# Test 2: Admin Stats API
# ==========================================

echo "📊 Test 2: Admin Stats API"
if [ -n "$ADMIN_TOKEN" ]; then
  STATS_RESPONSE=$(curl -s -H "Authorization: Bearer $ADMIN_TOKEN" "$BACKEND_URL/admin/stats" 2>/dev/null || echo "")
  USERS_TOTAL=$(echo "$STATS_RESPONSE" | jq -r '.usersTotal' 2>/dev/null || echo "null")
  HAS_SERIES=$(echo "$STATS_RESPONSE" | jq 'has("revenueSeries")' 2>/dev/null || echo "false")
  
  if [ "$USERS_TOTAL" != "null" ] && [ "$HAS_SERIES" == "true" ]; then
    test_result "Admin Stats API" "pass" "Users: $USERS_TOTAL, Revenue series present"
  else
    test_result "Admin Stats API" "fail" "Invalid response structure"
  fi
else
  test_result "Admin Stats API" "skip" "ADMIN_TOKEN not configured"
fi

# ==========================================
# Test 3: CSV Export Endpoint
# ==========================================

echo "📄 Test 3: CSV Export Endpoint"
if [ -n "$ADMIN_TOKEN" ]; then
  CSV_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    "$BACKEND_URL/admin/export/payments.csv" 2>/dev/null || echo "000")
  
  if [ "$CSV_STATUS" == "200" ]; then
    test_result "CSV Export" "pass" "HTTP $CSV_STATUS"
  else
    test_result "CSV Export" "fail" "HTTP $CSV_STATUS (expected 200)"
  fi
else
  test_result "CSV Export" "skip" "ADMIN_TOKEN not configured"
fi

# ==========================================
# Test 4: Jobs Health Check
# ==========================================

echo "⏰ Test 4: Jobs Health Check"
JOBS_HEALTH=$(curl -s "$BACKEND_URL/jobs/health" 2>/dev/null || echo "")
JOBS_STATUS=$(echo "$JOBS_HEALTH" | jq -r '.ok' 2>/dev/null || echo "false")

if [ "$JOBS_STATUS" == "true" ]; then
  test_result "Jobs Health" "pass" "Jobs service operational"
else
  test_result "Jobs Health" "fail" "Jobs service not responding"
fi

# ==========================================
# Test 5: Reminder Endpoint (Manual Trigger)
# ==========================================

echo "🔔 Test 5: Reminder Endpoint"
if [ -n "$CRON_SECRET" ]; then
  REMINDER_RESPONSE=$(curl -s -X POST \
    -H "X-Cron-Secret: $CRON_SECRET" \
    "$BACKEND_URL/jobs/send-reminders" 2>/dev/null || echo "")
  REMINDER_OK=$(echo "$REMINDER_RESPONSE" | jq -r '.ok' 2>/dev/null || echo "false")
  
  if [ "$REMINDER_OK" == "true" ]; then
    SENT_COUNT=$(echo "$REMINDER_RESPONSE" | jq -r '.sent' 2>/dev/null || echo "0")
    test_result "Reminder Endpoint" "pass" "Sent: $SENT_COUNT reminders"
  else
    test_result "Reminder Endpoint" "fail" "Endpoint not responding correctly"
  fi
else
  test_result "Reminder Endpoint" "skip" "CRON_SECRET not configured"
fi

# ==========================================
# Test 6: Chat Thread Creation
# ==========================================

echo "💬 Test 6: Chat API"
# Questo test richiede un token utente valido - skip per ora
test_result "Chat API" "skip" "Requires user token (test manually)"

# ==========================================
# Test 7: Firestore Connectivity
# ==========================================

echo "🔥 Test 7: Firestore Connectivity"
# Test indiretto via endpoint che usa Firestore
TEST_DB_RESPONSE=$(curl -s "$BACKEND_URL/test/db" 2>/dev/null || echo "")
TEST_DB_SUCCESS=$(echo "$TEST_DB_RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")

if [ "$TEST_DB_SUCCESS" == "true" ]; then
  test_result "Firestore Connectivity" "pass" "Database read/write OK"
else
  test_result "Firestore Connectivity" "fail" "Database connection issue"
fi

# ==========================================
# Test 8: Storage Connectivity
# ==========================================

echo "☁️  Test 8: Cloud Storage"
TEST_STORAGE_RESPONSE=$(curl -s "$BACKEND_URL/test/storage" 2>/dev/null || echo "")
TEST_STORAGE_SUCCESS=$(echo "$TEST_STORAGE_RESPONSE" | jq -r '.success' 2>/dev/null || echo "false")

if [ "$TEST_STORAGE_SUCCESS" == "true" ]; then
  test_result "Cloud Storage" "pass" "Storage read/write OK"
else
  test_result "Cloud Storage" "fail" "Storage connection issue"
fi

# ==========================================
# Test 9: Frontend Accessibility
# ==========================================

echo "🌐 Test 9: Frontend (Firebase Hosting)"
FRONTEND_URL="https://mypetcare.web.app"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>/dev/null || echo "000")

if [ "$FRONTEND_STATUS" == "200" ]; then
  test_result "Frontend Hosting" "pass" "HTTP $FRONTEND_STATUS"
else
  test_result "Frontend Hosting" "fail" "HTTP $FRONTEND_STATUS (expected 200)"
fi

# ==========================================
# Test 10: Cloud Scheduler Jobs
# ==========================================

echo "⏱️  Test 10: Cloud Scheduler Jobs"
# Verifica se i job sono configurati (richiede gcloud)
if command -v gcloud &> /dev/null; then
  SCHEDULER_JOBS=$(gcloud scheduler jobs list --location=europe-west1 --format="value(name)" 2>/dev/null | grep -E "booking-reminders|cleanup-locks" | wc -l)
  
  if [ "$SCHEDULER_JOBS" -ge 2 ]; then
    test_result "Cloud Scheduler" "pass" "$SCHEDULER_JOBS jobs configured"
  else
    test_result "Cloud Scheduler" "fail" "Expected 2+ jobs, found $SCHEDULER_JOBS"
  fi
else
  test_result "Cloud Scheduler" "skip" "gcloud not available"
fi

# ==========================================
# Manual Test Checklist
# ==========================================

echo "=========================================="
echo "📋 Manual Test Checklist"
echo "=========================================="
echo ""
echo "I seguenti test richiedono verifica manuale:"
echo ""
echo "  [ ] 1. Stripe Checkout → PDF generato su Storage"
echo "  [ ] 2. PayPal Capture → PDF generato su Storage"
echo "  [ ] 3. Booking creato → Reminder push ricevuto 24h prima"
echo "  [ ] 4. Chat 1:1 funzionante tra user e PRO"
echo "  [ ] 5. Dashboard admin mostra grafico aggiornato"
echo "  [ ] 6. Export CSV scarica file corretto"
echo "  [ ] 7. FCM notifiche attive su mobile/web"
echo "  [ ] 8. Logs Cloud Logging senza errori critici"
echo "  [ ] 9. Hosting Firebase sincronizzato (no cache vecchia)"
echo "  [ ] 10. Performance: response time < 500ms"
echo ""

# ==========================================
# Test Summary
# ==========================================

echo "=========================================="
echo "📊 Test Summary"
echo "=========================================="
echo ""

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))

echo -e "${GREEN}✅ Passed:  $TESTS_PASSED${NC}"
echo -e "${RED}❌ Failed:  $TESTS_FAILED${NC}"
echo -e "${YELLOW}⏭️  Skipped: $TESTS_SKIPPED${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Total:   $TOTAL_TESTS"
echo ""

# Pass rate
if [ $TOTAL_TESTS -gt 0 ]; then
  PASS_RATE=$(( (TESTS_PASSED * 100) / TOTAL_TESTS ))
  echo "Pass Rate: $PASS_RATE%"
  echo ""
fi

# Final verdict
if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 All automated tests passed!${NC}"
  echo ""
  echo "Procedi con i test manuali nella checklist sopra"
  EXIT_CODE=0
else
  echo -e "${RED}⚠️  $TESTS_FAILED test(s) failed${NC}"
  echo ""
  echo "Risolvi i problemi prima di procedere in produzione"
  EXIT_CODE=1
fi

echo ""
echo "=========================================="
echo ""

# Save results
cat > qa_results_$(date +%Y%m%d_%H%M%S).txt <<EOF
MyPetCare - Production QA Results
Generated: $(date)

Backend URL: $BACKEND_URL
Frontend URL: https://mypetcare.web.app

Test Results:
  Passed:  $TESTS_PASSED
  Failed:  $TESTS_FAILED
  Skipped: $TESTS_SKIPPED
  Total:   $TOTAL_TESTS

Pass Rate: ${PASS_RATE}%

Status: $([ $TESTS_FAILED -eq 0 ] && echo "READY FOR PRODUCTION ✅" || echo "ISSUES DETECTED ❌")
EOF

echo "💾 Risultati salvati in: qa_results_*.txt"
echo ""

exit $EXIT_CODE
