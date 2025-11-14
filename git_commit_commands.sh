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
