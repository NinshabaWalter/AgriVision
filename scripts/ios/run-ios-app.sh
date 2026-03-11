#!/bin/bash

# AgriVision iOS App Runner - Automatic Fix and Launch
# This script automatically fixes the app name and launches on iOS simulator

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Configuration
APP_NAME="AgriVision"
DISPLAY_NAME="AgriVision"
BUNDLE_ID="com.agrivision.app"
PROJECT_DIR="/Users/ninshaba/Desktop/Walter/Projects/AgriVision/mobile"

print_header "🌾 AgriVision iOS App - Auto Fix & Launch"
print_header "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    print_error "Flutter project not found at $PROJECT_DIR"
    exit 1
fi

print_status "Flutter project found ✓"

# Step 1: Fix iOS Info.plist
print_header "📱 Step 1: Fixing iOS App Name..."

INFO_PLIST="$PROJECT_DIR/ios/Runner/Info.plist"

if [ ! -f "$INFO_PLIST" ]; then
    print_error "Info.plist not found at $INFO_PLIST"
    exit 1
fi

# Update CFBundleDisplayName (this is what shows on the home screen)
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $DISPLAY_NAME" "$INFO_PLIST" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $DISPLAY_NAME" "$INFO_PLIST"

# Update CFBundleName
/usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$INFO_PLIST" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Add :CFBundleName string $APP_NAME" "$INFO_PLIST"

print_status "Updated iOS Info.plist with app name: $DISPLAY_NAME ✓"

# Step 2: Clean build cache
print_header "🧹 Step 2: Cleaning Build Cache..."

cd "$PROJECT_DIR"

# Flutter clean
flutter clean > /dev/null 2>&1
print_status "Flutter cache cleaned ✓"

# Remove build directory
if [ -d "build" ]; then
    rm -rf build
    print_status "Build directory removed ✓"
fi

# Step 3: Get dependencies
print_header "📦 Step 3: Getting Dependencies..."

flutter pub get > /dev/null 2>&1
print_status "Flutter dependencies updated ✓"

# Step 4: Verify the fix
print_header "✅ Step 4: Verifying Fix..."

DISPLAY_NAME_CHECK=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "$INFO_PLIST" 2>/dev/null || echo "Not set")
BUNDLE_NAME_CHECK=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$INFO_PLIST" 2>/dev/null || echo "Not set")

print_status "CFBundleDisplayName: $DISPLAY_NAME_CHECK"
print_status "CFBundleName: $BUNDLE_NAME_CHECK"

if [ "$DISPLAY_NAME_CHECK" = "$DISPLAY_NAME" ]; then
    print_success "✅ App display name correctly set to: $DISPLAY_NAME"
else
    print_warning "⚠️ App display name may not be set correctly"
fi

# Step 5: Launch on simulator
print_header "🚀 Step 5: Launching on iOS Simulator..."

# Check available simulators
SIMULATOR_COUNT=$(xcrun simctl list devices available | grep iPhone | wc -l)
if [ "$SIMULATOR_COUNT" -eq 0 ]; then
    print_error "No iPhone simulators found"
    print_error "Please open Xcode and create an iPhone simulator"
    exit 1
fi

print_status "Found $SIMULATOR_COUNT available iPhone simulators"

# Show available simulators
print_status "Available simulators:"
xcrun simctl list devices available | grep iPhone | head -5

echo ""
print_header "🎯 Launching AgriVision..."
print_status "This will open the iOS Simulator and launch your app"
print_status "The app name should now appear as 'AgriVision' on the home screen"
echo ""

# Launch the app
flutter run --debug

print_success "🎉 Done! Your app should now show 'AgriVision' as the name on the iOS simulator home screen."