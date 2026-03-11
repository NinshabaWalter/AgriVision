#!/bin/bash

# AgriVision App Status Checker
# This script checks if the app is running and shows the current configuration

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

PROJECT_DIR="/Users/ninshaba/Desktop/Walter/Projects/AgriVision/mobile"

print_header "🌾 AgriVision App Status Check"
print_header "=============================="
echo ""

# Check if simulator is running
print_header "📱 iOS Simulator Status"
SIMULATOR_STATUS=$(xcrun simctl list devices | grep Booted | wc -l)
if [ "$SIMULATOR_STATUS" -gt 0 ]; then
    print_status "iOS Simulator is running ✓"
    xcrun simctl list devices | grep Booted
else
    print_warning "No iOS Simulator currently running"
fi
echo ""

# Check current app configuration
print_header "⚙️ App Configuration"
INFO_PLIST="$PROJECT_DIR/ios/Runner/Info.plist"

if [ -f "$INFO_PLIST" ]; then
    DISPLAY_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "$INFO_PLIST" 2>/dev/null || echo "Not set")
    BUNDLE_NAME=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$INFO_PLIST" 2>/dev/null || echo "Not set")
    
    print_status "Display Name (Home Screen): $DISPLAY_NAME"
    print_status "Bundle Name (Internal): $BUNDLE_NAME"
    
    if [ "$DISPLAY_NAME" = "AgriVision" ]; then
        print_status "✅ App name correctly configured!"
    else
        print_warning "⚠️ App name may need fixing"
    fi
else
    print_warning "Info.plist not found"
fi
echo ""

# Check if Flutter process is running
print_header "🔄 Flutter Process Status"
FLUTTER_PROCESSES=$(ps aux | grep "flutter run" | grep -v grep | wc -l)
if [ "$FLUTTER_PROCESSES" -gt 0 ]; then
    print_status "Flutter app is running ✓"
    print_status "Active Flutter processes: $FLUTTER_PROCESSES"
else
    print_warning "No Flutter processes detected"
fi
echo ""

# Check available devices
print_header "📱 Available Devices"
cd "$PROJECT_DIR"
flutter devices --machine 2>/dev/null | head -5 || echo "Unable to get device list"
echo ""

print_header "🎯 Quick Actions"
echo "• To launch app: ./run-ios-app.sh"
echo "• To diagnose issues: ./diagnose-ios-app.sh"
echo "• To stop running app: Press Ctrl+C in the terminal running Flutter"
echo "• To restart app: Press 'r' in the Flutter terminal"
echo "• To hot reload: Press 'R' in the Flutter terminal"
echo ""

print_status "Status check complete!"