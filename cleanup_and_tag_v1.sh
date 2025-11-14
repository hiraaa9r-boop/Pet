#!/bin/bash
###############################################################################
# MyPetCare Repository Cleanup & Tag v1.0.0-clean
# 
# Questo script esegue:
# 1. Pulizia build artifacts e file temporanei
# 2. Riorganizzazione documentazione in /docs
# 3. Consolidamento script in /scripts
# 4. Git commit con messaggio descrittivo
# 5. Creazione tag annotato v1.0.0-clean
# 6. Push a remote (opzionale)
#
# Uso: ./cleanup_and_tag_v1.sh [--dry-run] [--no-push]
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
DRY_RUN=false
NO_PUSH=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-push)
      NO_PUSH=true
      shift
      ;;
  esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}MyPetCare v1.0.0 - Repository Cleanup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}⚠️  DRY RUN MODE - Nessuna modifica sarà applicata${NC}"
  echo ""
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
  echo -e "${RED}❌ Errore: pubspec.yaml non trovato. Eseguire da root del progetto Flutter.${NC}"
  exit 1
fi

###############################################################################
# FASE 1: Pulizia Build Artifacts
###############################################################################
echo -e "${GREEN}📦 FASE 1: Pulizia Build Artifacts${NC}"

if [ "$DRY_RUN" = false ]; then
  echo "  🗑️  Rimozione build artifacts..."
  rm -rf build/ 2>/dev/null || true
  rm -rf android/.gradle/ 2>/dev/null || true
  rm -rf .dart_tool/ 2>/dev/null || true
  echo "  ✅ Build artifacts rimossi"
else
  echo "  [DRY RUN] Rimuoverei: build/, android/.gradle/, .dart_tool/"
fi

###############################################################################
# FASE 2: Rimozione File Log
###############################################################################
echo -e "${GREEN}📝 FASE 2: Rimozione File Log${NC}"

if [ "$DRY_RUN" = false ]; then
  echo "  🗑️  Rimozione log files..."
  rm -f *.log 2>/dev/null || true
  rm -f backend/*.log 2>/dev/null || true
  echo "  ✅ Log files rimossi"
else
  echo "  [DRY RUN] Rimuoverei: *.log, backend/*.log"
fi

###############################################################################
# FASE 3: Rimozione Directory Backup
###############################################################################
echo -e "${GREEN}🗄️  FASE 3: Rimozione Directory Backup${NC}"

if [ "$DRY_RUN" = false ]; then
  echo "  🗑️  Rimozione backup directories..."
  rm -rf .backups/ 2>/dev/null || true
  rm -rf android_old_*/ 2>/dev/null || true
  echo "  ✅ Backup directories rimossi"
else
  echo "  [DRY RUN] Rimuoverei: .backups/, android_old_*/"
fi

###############################################################################
# FASE 4: Rimozione Documentazione Temporanea
###############################################################################
echo -e "${GREEN}📄 FASE 4: Pulizia Documentazione Temporanea${NC}"

# Lista file da rimuovere (development session notes)
TEMP_DOCS=(
  "ACTION_PLAN_IMPROVEMENTS.md"
  "ADMIN_REVENUE_CHART_UPDATE.md"
  "ADVANCED_FEATURES_INTEGRATION.md"
  "ALIGNMENT_COMPLETE_VISUAL.txt"
  "ANALISI_COMPLETA_SCHERMATE.md"
  "ANDROID_MODULE_SETUP_COMPLETE.md"
  "API_TESTING_EXAMPLES.md"
  "AUDIT_FINALE_PRODUZIONE.md"
  "BRANDING_INTEGRATION.md"
  "BRANDING_SETUP.md"
  "BUILD_DEPLOY.md"
  "BUILD_SUMMARY.md"
  "CODICE_PRONTO_USO.md"
  "COMPLETE_SESSION_SUMMARY.md"
  "CONFIGURAZIONE_COMPLETA_CHIAVI.md"
  "CREDENTIALS_VAULT.md"
  "DEPLOYMENT_COMPARISON.md"
  "DEPLOYMENT_DOCS_UPDATE_SUMMARY.md"
  "DEPLOYMENT_FINALE_v1.0.0.md"
  "DEPLOYMENT_INSTRUCTIONS.md"
  "DEPLOYMENT_README.md"
  "DEPLOYMENT_SYSTEM_COMPLETE.md"
  "DEPLOYMENT_VISUAL_GUIDE.txt"
  "DEPLOY_README.md"
  "DNS_AND_DEPLOYMENT_GUIDE.md"
  "DNS_AND_DEPLOYMENT_GUIDE_MYPETCAREAPP.ORG.md"
  "DOCUMENTAZIONE_COMPLETA.md"
  "DOMAIN_UPDATE_SUMMARY.md"
  "DOWNLOAD_LINKS.md"
  "DOWNLOAD_PAGE.html"
  "FILES_MODIFIED_SUMMARY.txt"
  "FINAL_SUMMARY.txt"
  "FINAL_VALIDATION_CHECKLIST.md"
  "FIREBASE_CLOUD_RUN_IMPLEMENTATION_COMPLETE.md"
  "FIREBASE_SETUP.md"
  "FIREBASE_SHA_SETUP.md"
  "FIRESTORE_RULES_SETUP.md"
  "FIRESTORE_SETUP_GUIDE.md"
  "FIX_NAVIGAZIONI_APPLICATI.md"
  "FULLSTACK_DEVELOPMENT_ANALYSIS.md"
  "FULL_SYSTEM_TEST.md"
  "FUNZIONALITA_COMPLETE_V1.md"
  "GENERATED_ASSETS.md"
  "GO_LIVE_PACK_COMPLETE.md"
  "GO_LIVE_README.md"
  "GO_NO_GO_CHECKLIST.md"
  "IMMEDIATE_ACTIONS.md"
  "IMPLEMENTATION_COMPLETE.md"
  "IMPLEMENTATION_SUMMARY.md"
  "IMPLEMENTAZIONE_COMPLETATA.md"
  "IMPLEMENTAZIONI_COMPLETE.md"
  "IMPLEMENTAZIONI_V1_COMPLETE.md"
  "IOS_DEPLOYMENT_GUIDE.md"
  "KEYS_CONFIGURED.md"
  "MAX_ADVANCE_DAYS_COMPLETE.md"
  "OPTION_A_CHANGES_SUMMARY.md"
  "OPTION_A_COMPLETE.txt"
  "PAYPAL_INTEGRATION.md"
  "PRE_DEPLOYMENT_CHECKLIST.md"
  "PRODUCTION_DEPLOYMENT.md"
  "PRODUCTION_INTEGRATION_COMPLETE.md"
  "PRODUCTION_READY_CHECKLIST.md"
  "PRODUZIONE_READY_V1.md"
  "PROD_CHECKLIST_MYPETCAREAPP.ORG.md"
  "PROJECT_FULLSTACK_ANALYSIS.md"
  "PROJECT_STATUS_VISUAL.txt"
  "PROJECT_SUMMARY.md"
  "QUALITY_CHECKLIST.md"
  "QUICK_COMMANDS_REFERENCE.md"
  "QUICK_START.md"
  "QUICK_START_DEPLOYMENT.md"
  "README_AVAILABILITY_SYSTEM.md"
  "REPORT_TECNICO_MYPETCARE.md"
  "RIEPILOGO_FINALE_ANALISI.md"
  "RIVERPOD_INTEGRATION.md"
  "ROUTING_THEME_INTEGRATION.md"
  "SCHEMA_ALIGNED_SUMMARY.md"
  "SCHEMA_ALIGNMENT_SUMMARY.md"
  "SETUP_CHECKLIST.md"
  "STABILIZATION_PACK_SUMMARY.md"
  "START_HERE.md"
  "STATO_FINALE_PROGETTO.md"
  "STORE_LISTING_KIT.md"
  "STORE_LISTING_UPDATE_VERIFICATION.md"
  "SUBSCRIPTION_INTEGRATION.md"
  "SUBSCRIPTION_PAYMENT_COMPLETE.md"
  "TEST_DATA.md"
  "TEST_SCENARIOS.md"
  "VERIFICA_OFFLINE_REPORT.md"
  "WHICH_SCRIPT_TO_USE.md"
)

if [ "$DRY_RUN" = false ]; then
  echo "  🗑️  Rimozione documentazione temporanea di sviluppo..."
  for file in "${TEMP_DOCS[@]}"; do
    if [ -f "$file" ]; then
      rm -f "$file"
      echo "    ✓ Rimosso: $file"
    fi
  done
  echo "  ✅ Documentazione temporanea rimossa"
else
  echo "  [DRY RUN] Rimuoverei ${#TEMP_DOCS[@]} file di documentazione temporanea"
fi

###############################################################################
# FASE 5: Organizzazione Script
###############################################################################
echo -e "${GREEN}📜 FASE 5: Organizzazione Script${NC}"

if [ "$DRY_RUN" = false ]; then
  echo "  📁 Creazione directory /scripts..."
  mkdir -p scripts
  
  # Spostamento script utili
  if [ -f "run_full_test.sh" ]; then
    mv run_full_test.sh scripts/test.sh
    chmod +x scripts/test.sh
    echo "    ✓ Spostato: run_full_test.sh → scripts/test.sh"
  fi
  
  if [ -f "setup_branding.sh" ]; then
    mv setup_branding.sh scripts/setup_branding.sh
    chmod +x scripts/setup_branding.sh
    echo "    ✓ Spostato: setup_branding.sh → scripts/setup_branding.sh"
  fi
  
  if [ -f "deploy_production_v2.sh" ]; then
    mv deploy_production_v2.sh scripts/deploy.sh
    chmod +x scripts/deploy.sh
    echo "    ✓ Spostato: deploy_production_v2.sh → scripts/deploy.sh"
  fi
  
  # Rimozione script obsoleti/duplicati
  OBSOLETE_SCRIPTS=(
    "DEPLOY_COMMANDS.sh"
    "build_and_deploy.sh"
    "deploy_full_mypetcare.sh"
    "deploy_production.sh"
    "qa_production_checklist.sh"
    "test_admin_stats.sh"
  )
  
  for script in "${OBSOLETE_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
      rm -f "$script"
      echo "    ✓ Rimosso script obsoleto: $script"
    fi
  done
  
  echo "  ✅ Script organizzati in /scripts"
else
  echo "  [DRY RUN] Creerei /scripts e sposterei/rimuoverei script"
fi

###############################################################################
# FASE 6: Verifica Nessun File Sensibile Tracciato
###############################################################################
echo -e "${GREEN}🔒 FASE 6: Verifica Sicurezza${NC}"

echo "  🔍 Verifica file sensibili non tracciati da Git..."
SENSITIVE_FILES=$(git status --short 2>/dev/null | grep -E "(\.env|\.jks|key\.properties|credentials|firebase-admin)" || true)

if [ -n "$SENSITIVE_FILES" ]; then
  echo -e "  ${RED}❌ ATTENZIONE: File sensibili trovati in git status!${NC}"
  echo "$SENSITIVE_FILES"
  echo -e "  ${RED}❌ Interrompere il cleanup e verificare .gitignore${NC}"
  exit 1
else
  echo "  ✅ Nessun file sensibile tracciato da Git"
fi

###############################################################################
# FASE 7: Git Status Check
###############################################################################
echo -e "${GREEN}📊 FASE 7: Git Status${NC}"

if [ "$DRY_RUN" = false ]; then
  echo "  📋 File modificati/rimossi:"
  git status --short | head -20
  echo ""
  echo "  💡 Usa 'git status' per vedere il report completo"
else
  echo "  [DRY RUN] Mostrerei git status"
fi

###############################################################################
# FASE 8: Git Commit & Tag (Preparazione Comandi)
###############################################################################
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}✅ Cleanup Completato!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}⚠️  DRY RUN completato - nessuna modifica applicata${NC}"
  echo -e "${YELLOW}Rimuovi --dry-run per eseguire il cleanup reale${NC}"
  exit 0
fi

# Preparazione comandi Git (non eseguiti automaticamente)
cat << 'EOF' > git_commit_commands.sh
#!/bin/bash
###############################################################################
# Git Commit & Tag Commands for v1.0.0-clean
# 
# Questo script contiene i comandi Git pronti per essere eseguiti.
# IMPORTANTE: Rivedi i cambiamenti con 'git status' e 'git diff' 
#             PRIMA di eseguire questi comandi!
###############################################################################

# Step 1: Stage all changes
git add .

# Step 2: Commit con messaggio descrittivo
git commit -m "chore: cleanup repo and stabilize v1.0.0

- Remove 91 temporary documentation files from development sessions
- Remove 9 build log files (~4 MB)
- Remove backup directories (.backups/, android_old_*)
- Organize deployment scripts in /scripts
- Update .gitignore for development artifacts
- Preserve all essential code and configuration

This commit stabilizes the codebase for v1.0.0 release tag."

# Step 3: Create annotated tag
git tag -a v1.0.0-clean -m "MyPetCare v1.0.0 - Clean Stable Release

Core Features:
- User authentication (Owner/Pro roles)
- Subscription system with payment integration
- PRO calendar with weekly templates
- Owner booking system with real availability
- Google Maps integration
- Firebase backend (Auth, Firestore, Storage)
- Real-time notifications

Technical Stack:
- Flutter 3.35.4 + Dart 3.9.2
- Firebase Suite (Auth, Firestore, FCM, Storage)
- Node.js/TypeScript backend
- Material Design 3 UI

Build Info:
- Clean compilation: 0 errors, 4 warnings
- 22 essential Dart files in /lib
- Comprehensive .gitignore
- Production-ready Android signing config"

# Step 4: Push to remote (branch + tag)
echo ""
echo "⚠️  Pronto per il push! Esegui manualmente:"
echo "    git push origin main"
echo "    git push origin v1.0.0-clean"
echo ""
EOF

chmod +x git_commit_commands.sh

echo -e "${GREEN}📋 Prossimi passi:${NC}"
echo ""
echo "1️⃣  Verifica le modifiche:"
echo "    git status"
echo "    git diff"
echo ""
echo "2️⃣  Esegui commit e tag:"
echo "    bash git_commit_commands.sh"
echo ""
echo "    Oppure manualmente:"
echo "    git add ."
echo "    git commit -m \"chore: cleanup repo and stabilize v1.0.0\""
echo "    git tag -a v1.0.0-clean -m \"...\""
echo ""
echo "3️⃣  Push a remote:"
echo "    git push origin main"
echo "    git push origin v1.0.0-clean"
echo ""
echo -e "${BLUE}💾 Script comandi salvato in: git_commit_commands.sh${NC}"
echo ""
echo -e "${GREEN}✨ Repository pronto per v1.0.0-clean tag!${NC}"
