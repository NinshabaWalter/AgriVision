#!/bin/bash

# AgriVision Project Organization Script
# This script organizes all project files into clean, logical folders

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

PROJECT_ROOT="/Users/ninshaba/Desktop/Walter/Projects/AgriVision"

print_header "AgriVision Project Organization"
print_header "=================================="
echo ""

cd "$PROJECT_ROOT"

# Create organized folder structure
print_header "📁 Creating Organized Folder Structure..."

# Main folders
mkdir -p docs/{api,deployment,guides,project-info}
mkdir -p scripts/{ios,api,deployment,testing}
mkdir -p legacy/{api-versions,backend-versions,test-files}
mkdir -p config/{environment,docker}

print_status "Created main folder structure ✓"

# Move documentation files
print_header "📚 Organizing Documentation..."

# API Documentation
mv README-API.md docs/api/ 2>/dev/null || true
mv README-ENHANCED-API.md docs/api/ 2>/dev/null || true
mv iOS-APP-NAME-GUIDE.md docs/guides/ 2>/dev/null || true

# Deployment Documentation
mv DEPLOYMENT.md docs/deployment/ 2>/dev/null || true
mv DEPLOYMENT-ENHANCED.md docs/deployment/ 2>/dev/null || true

# Project Information
mv AGRIVISION_COMPREHENSIVE_FEATURES_SUMMARY.md docs/project-info/ 2>/dev/null || true
mv FINAL_PROJECT_SUMMARY.md docs/project-info/ 2>/dev/null || true
mv IMPLEMENTATION_SUMMARY.md docs/project-info/ 2>/dev/null || true
mv PROJECT_STRUCTURE.md docs/project-info/ 2>/dev/null || true
mv AGRIVISION-SETUP-COMPLETE.md docs/project-info/ 2>/dev/null || true
mv RUN_AGRIVISION.md docs/guides/ 2>/dev/null || true

# Development Documentation
mv CHANGELOG.md docs/project-info/ 2>/dev/null || true
mv CLEANUP_SUMMARY.md docs/project-info/ 2>/dev/null || true
mv CONTRIBUTING.md docs/project-info/ 2>/dev/null || true

print_status "Documentation organized ✓"

# Move script files
print_header "🔧 Organizing Scripts..."

# iOS Scripts
mv check-app-status.sh scripts/ios/ 2>/dev/null || true
mv diagnose-ios-app.sh scripts/ios/ 2>/dev/null || true
mv fix-ios-app-name.sh scripts/ios/ 2>/dev/null || true
mv run-ios-app.sh scripts/ios/ 2>/dev/null || true

# API Scripts
mv start-api.sh scripts/api/ 2>/dev/null || true
mv start-enhanced-api.sh scripts/api/ 2>/dev/null || true
mv start-organized-api.sh scripts/api/ 2>/dev/null || true
mv quick-start.sh scripts/api/ 2>/dev/null || true

# Test Scripts
mv test-api.js scripts/testing/ 2>/dev/null || true
mv test-enhanced-api.js scripts/testing/ 2>/dev/null || true

print_status "Scripts organized ✓"

# Move legacy API files
print_header "📦 Organizing Legacy Files..."

# Legacy API versions
mv api-gateway.js legacy/api-versions/ 2>/dev/null || true
mv api-gateway-enhanced.js legacy/api-versions/ 2>/dev/null || true
mv api-gateway-complete.js legacy/api-versions/ 2>/dev/null || true
mv api-gateway-features.js legacy/api-versions/ 2>/dev/null || true

# Legacy backend files
mv backend_server.py legacy/backend-versions/ 2>/dev/null || true
mv simple_backend.py legacy/backend-versions/ 2>/dev/null || true

print_status "Legacy files organized ✓"

# Move configuration files
print_header "⚙️ Organizing Configuration Files..."

# Environment files
mv .env.enhanced config/environment/ 2>/dev/null || true
mv .env.example config/environment/ 2>/dev/null || true

# Docker files
mv Dockerfile config/docker/ 2>/dev/null || true
mv docker-compose.yml config/docker/ 2>/dev/null || true

print_status "Configuration files organized ✓"

# Move middleware (legacy - since we have organized API now)
print_header "🔄 Organizing Legacy Middleware..."
if [ -d "middleware" ]; then
    mv middleware legacy/
    print_status "Legacy middleware moved ✓"
fi

print_status "Project organization complete ✓"