#!/bin/bash

# AgriVision iOS App Diagnostic Script
# This script diagnoses common iOS app name and build issues

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

PROJECT_DIR="/Users/ninshaba/Desktop/Walter/Projects/AgriVision/mobile"

print_header "🔍 AgriVision iOS App Diagnostic Report"
print_header "======================================="
echo ""

# Check Flutter installation
print_header "1. Flutter Environment"
if command -v flutter &> /dev/null; then
    flutter --version | head -3
    print_status "Flutter is installed ✓"
else
    print_error "Flutter is not installed ❌"
fi
echo ""

# Check Xcode installation
print_header "2. Xcode Environment"
if command -v xcodebuild &> /dev/null; then
    xcodebuild -version
    print_status "Xcode is installed ✓"
else
    print_error "Xcode is not installed ❌"
fi
echo ""

# Check iOS Simulators
print_header "3. iOS Simulators"
if command -v xcrun &> /dev/null; then
    SIMULATOR_COUNT=$(xcrun simctl list devices available | grep iPhone | wc -l)
    print_status "Available iPhone simulators: $SIMULATOR_COUNT"
    if [ "$SIMULATOR_COUNT" -gt 0 ]; then
        print_status "iOS Simulators available ✓"
        echo "Available simulators:"
        xcrun simctl list devices available | grep iPhone | head -5
    else
        print_error "No iOS simulators found ❌"
    fi
else
    print_error "xcrun not available ❌"
fi
echo ""

# Check project structure
print_header "4. Project Structure"
if [ -f "$PROJECT_DIR/pubspec.yaml" ]; then
    print_status "Flutter project found ✓"
    
    # Check pubspec.yaml content
    APP_NAME=$(grep "^name:" "$PROJECT_DIR/pubspec.yaml" | cut -d' ' -f2)
    print_status "Current app name in pubspec.yaml: $APP_NAME"
    
    if [ -d "$PROJECT_DIR/ios" ]; then
        print_status "iOS project directory exists ✓"
    else
        print_error "iOS project directory missing ❌"
    fi
else
    print_error "Flutter project not found ❌"
fi
echo ""

# Check iOS configuration
print_header "5. iOS Configuration"
INFO_PLIST="$PROJECT_DIR/ios/Runner/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    print_status "Info.plist found ✓"
    
    # Check app names in Info.plist
    DISPLAY_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "$INFO_PLIST" 2>/dev/null || echo "Not set")
    BUNDLE_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$INFO_PLIST" 2>/dev/null || echo "Not set")
    BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$INFO_PLIST" 2>/dev/null || echo "Not set")
    
    print_status "CFBundleDisplayName (Home screen name): $DISPLAY_NAME"
    print_status "CFBundleName (App name): $BUNDLE_NAME"
    print_status "CFBundleIdentifier: $BUNDLE_ID"
    
    if [ "$DISPLAY_NAME" = "Not set" ] || [ "$DISPLAY_NAME" = "Agricultural Platform" ]; then
        print_warning "Display name needs to be updated ⚠️"
    else
        print_status "Display name looks good ✓"
    fi
else
    print_error "Info.plist not found ❌"
fi
echo ""

# Check for build artifacts that might cause issues
print_header "6. Build Artifacts"
if [ -d "$PROJECT_DIR/build" ]; then
    BUILD_SIZE=$(du -sh "$PROJECT_DIR/build" 2>/dev/null | cut -f1)
    print_warning "Build directory exists ($BUILD_SIZE) - may need cleaning"
else
    print_status "No build directory (clean state) ✓"
fi

if [ -d "$PROJECT_DIR/ios/build" ]; then
    print_warning "iOS build directory exists - may need cleaning"
else
    print_status "No iOS build directory (clean state) ✓"
fi

# Check for derived data
DERIVED_DATA_COUNT=$(find "$HOME/Library/Developer/Xcode/DerivedData" -name "*agricultural*" -o -name "*AgriVision*" 2>/dev/null | wc -l)
if [ "$DERIVED_DATA_COUNT" -gt 0 ]; then
    print_warning "Found $DERIVED_DATA_COUNT related derived data entries - may need cleaning"
else
    print_status "No conflicting derived data ✓"
fi
echo ""

# Check Flutter doctor
print_header "7. Flutter Doctor"
flutter doctor --verbose | head -20
echo ""

# Recommendations
print_header "🎯 Recommendations"
print_header "=================="

if [ "$DISPLAY_NAME" = "Not set" ] || [ "$DISPLAY_NAME" = "Agricultural Platform" ]; then
    echo "❗ ISSUE: App display name needs updating"
    echo "   SOLUTION: Run ./fix-ios-app-name.sh and choose option 1 or 2"
    echo ""
fi

if [ ! -d "$PROJECT_DIR/ios" ]; then
    echo "❗ ISSUE: iOS project missing"
    echo "   SOLUTION: Run 'flutter create --platforms ios .' in the mobile directory"
    echo ""
fi

if [ "$SIMULATOR_COUNT" -eq 0 ]; then
    echo "❗ ISSUE: No iOS simulators available"
    echo "   SOLUTION: Open Xcode → Window → Devices and Simulators → Add simulator"
    echo ""
fi

if [ -d "$PROJECT_DIR/build" ]; then
    echo "💡 SUGGESTION: Clean build cache for fresh start"
    echo "   SOLUTION: Run ./fix-ios-app-name.sh and choose option 4"
    echo ""
fi

print_header "🚀 Quick Start Commands"
print_header "======================"
echo "1. Fix app name and launch:     ./fix-ios-app-name.sh"
echo "2. Manual Flutter commands:"
echo "   cd mobile"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run"
echo ""

print_header "📱 Manual Xcode Fix (Alternative)"
print_header "================================="
echo "1. Open mobile/ios/Runner.xcworkspace in Xcode"
echo "2. Select 'Runner' target in the navigator"
echo "3. Go to 'General' tab"
echo "4. Change 'Display Name' to 'AgriVision'"
echo "5. Clean build folder (Product → Clean Build Folder)"
echo "6. Run the app (Product → Run)"
echo ""

print_status "Diagnostic complete! Use the recommendations above to fix any issues."