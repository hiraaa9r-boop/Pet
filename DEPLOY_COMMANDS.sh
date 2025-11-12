#!/bin/bash

# ============================================
# MY PET CARE - Availability System Deploy
# ============================================
# 
# Questo script contiene i comandi per deployare
# l'intero sistema di availability su Firebase
#
# Usage: bash DEPLOY_COMMANDS.sh
# ============================================

set -e  # Exit on error

echo "============================================"
echo "MY PET CARE - Availability System Deploy"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================
# STEP 1: Deploy Cloud Functions
# ============================================
echo -e "${BLUE}STEP 1: Deploy Cloud Functions${NC}"
echo "Deploying cleanupExpiredLocks function..."
echo ""

cd backend/functions

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}Installing dependencies...${NC}"
  npm install
fi

# Deploy function
firebase deploy --only functions:cleanupExpiredLocks

echo -e "${GREEN}✅ Cloud Functions deployed!${NC}"
echo ""

# ============================================
# STEP 2: Deploy Firestore Rules
# ============================================
echo -e "${BLUE}STEP 2: Deploy Firestore Rules${NC}"
echo "Deploying security rules..."
echo ""

cd ../..  # Back to project root

firebase deploy --only firestore:rules

echo -e "${GREEN}✅ Firestore Rules deployed!${NC}"
echo ""

# ============================================
# STEP 3: Deploy Firestore Indexes
# ============================================
echo -e "${BLUE}STEP 3: Deploy Firestore Indexes${NC}"
echo "Deploying indexes..."
echo ""

firebase deploy --only firestore:indexes

echo -e "${GREEN}✅ Firestore Indexes deployed!${NC}"
echo ""

# ============================================
# STEP 4: Test Backend Locally (Optional)
# ============================================
echo -e "${BLUE}STEP 4: Test Backend Locally (Optional)${NC}"
echo "You can test the backend locally before deploying:"
echo ""
echo -e "${YELLOW}cd backend${NC}"
echo -e "${YELLOW}npm run dev${NC}"
echo -e "${YELLOW}./test-availability.sh http://localhost:8080${NC}"
echo ""
read -p "Do you want to skip local testing and deploy directly? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Skipping deployment. Please test locally first.${NC}"
  exit 0
fi

# ============================================
# STEP 5: Deploy Backend to Cloud Run (Example)
# ============================================
echo -e "${BLUE}STEP 5: Deploy Backend API${NC}"
echo "This example uses Cloud Run. Adjust for your platform."
echo ""

cd backend

# Check if .env exists
if [ ! -f ".env" ]; then
  echo -e "${RED}ERROR: .env file not found!${NC}"
  echo "Please create backend/.env with required environment variables."
  exit 1
fi

# Build and deploy (Cloud Run example)
echo -e "${YELLOW}Deploying to Cloud Run...${NC}"
# gcloud run deploy my-pet-care-api \
#   --source . \
#   --region europe-west1 \
#   --platform managed \
#   --allow-unauthenticated \
#   --set-env-vars NODE_ENV=production

echo -e "${YELLOW}⚠️  Manual step required:${NC}"
echo "Deploy backend to your preferred platform:"
echo "  • Cloud Run: gcloud run deploy ..."
echo "  • App Engine: gcloud app deploy"
echo "  • Other: Follow your platform's deployment guide"
echo ""

# ============================================
# STEP 6: Build and Deploy Flutter Web
# ============================================
echo -e "${BLUE}STEP 6: Build and Deploy Flutter Web${NC}"
echo "Building Flutter web app..."
echo ""

cd ..

# Build Flutter web
flutter build web --release

echo -e "${GREEN}✅ Flutter web built!${NC}"
echo ""

# Deploy to Firebase Hosting
echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo -e "${GREEN}✅ Flutter web deployed!${NC}"
echo ""

# ============================================
# STEP 7: Verification
# ============================================
echo -e "${BLUE}STEP 7: Verification${NC}"
echo "Please verify the deployment:"
echo ""
echo "1. Cloud Functions:"
echo "   firebase functions:log --only cleanupExpiredLocks"
echo ""
echo "2. Firestore Rules:"
echo "   Firebase Console → Firestore → Rules"
echo ""
echo "3. Firestore Indexes:"
echo "   Firebase Console → Firestore → Indexes"
echo ""
echo "4. Backend API:"
echo "   curl https://api.mypetcare.it/health | jq"
echo ""
echo "5. Availability Endpoint:"
echo "   curl \"https://api.mypetcare.it/api/pros/TEST_PRO_ID/availability?date=2025-11-20\" | jq"
echo ""
echo "6. Flutter Web:"
echo "   Open https://app.mypetcare.it in browser"
echo ""

# ============================================
# STEP 8: Create Test Data (Optional)
# ============================================
echo -e "${BLUE}STEP 8: Create Test Data (Optional)${NC}"
echo ""
read -p "Do you want to create test calendar data? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  cd backend
  node scripts/create-test-calendar.js
  echo -e "${GREEN}✅ Test calendar created!${NC}"
fi

# ============================================
# COMPLETE
# ============================================
echo ""
echo "============================================"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Verify all deployments (see verification steps above)"
echo "2. Test availability endpoint with real PRO IDs"
echo "3. Monitor Cloud Functions logs for lock cleanup"
echo "4. Test Flutter SlotGrid widget in production"
echo ""
echo "Documentation:"
echo "  • Complete guide: backend/AVAILABILITY_DEPLOYMENT_GUIDE.md"
echo "  • Quick reference: backend/AVAILABILITY_QUICK_REFERENCE.md"
echo "  • Implementation summary: IMPLEMENTATION_COMPLETE.md"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
