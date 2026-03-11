#!/bin/bash

# AgriVision iOS Simulator Runner
# This script starts the iOS simulator and runs the Flutter app

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

PROJECT_ROOT="/Users/ninshaba/Desktop/Walter/Projects/AgriVision"
MOBILE_DIR="$PROJECT_ROOT/mobile"

print_header "🍎 AgriVision iOS Simulator Runner"
print_header "=================================="
echo ""

# Check if we're in the right directory
if [ ! -d "$MOBILE_DIR" ]; then
    print_error "Mobile directory not found at $MOBILE_DIR"
    exit 1
fi

cd "$MOBILE_DIR"

# Check available simulators
print_status "Checking available iOS simulators..."
SIMULATORS=$(xcrun simctl list devices | grep "iPhone 16 Pro" | grep "Shutdown" | head -1)

if [ -z "$SIMULATORS" ]; then
    print_warning "No shutdown iPhone 16 Pro simulators found. Checking for running ones..."
    RUNNING_SIM=$(xcrun simctl list devices | grep "iPhone 16 Pro" | grep "Booted" | head -1)
    
    if [ -z "$RUNNING_SIM" ]; then
        print_error "No iPhone 16 Pro simulators available"
        print_status "Available simulators:"
        xcrun simctl list devices | grep "iPhone"
        exit 1
    else
        print_status "Found running iPhone 16 Pro simulator"
    fi
else
    # Extract simulator ID
    SIM_ID=$(echo "$SIMULATORS" | grep -o '[A-F0-9-]\{36\}')
    print_status "Starting iPhone 16 Pro simulator (ID: $SIM_ID)..."
    xcrun simctl boot "$SIM_ID"
    
    # Wait a moment for simulator to boot
    sleep 3
fi

# Check Flutter devices
print_status "Checking Flutter devices..."
flutter devices

# Run the app
print_status "Launching AgriVision on iOS simulator..."
print_warning "This may take a few minutes for the first run..."

# Explicitly target iPhone 16 Pro to avoid ambiguity when multiple devices are available
flutter run -d "iPhone 16 Pro"

print_status "✅ App launched successfully!"