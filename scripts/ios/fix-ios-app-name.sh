#!/bin/bash

# AgriVision iOS App Name Fix and Simulator Launch Script
# This script fixes the iOS app name display issue and launches the app on simulator

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if we're in the right directory
check_directory() {
    if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
        print_error "Flutter project not found at $PROJECT_DIR"
        print_error "Please make sure you're running this script from the correct location"
        exit 1
    fi
    
    if [ ! -d "$PROJECT_DIR/ios" ]; then
        print_error "iOS project not found. Please make sure Flutter iOS project is set up"
        exit 1
    fi
    
    print_status "Flutter project found ✓"
}

# Check prerequisites
check_prerequisites() {
    print_header "🔍 Checking Prerequisites..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        print_error "Please install Flutter from https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_status "Flutter: $FLUTTER_VERSION ✓"
    
    # Check Xcode
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed or command line tools are not set up"
        print_error "Please install Xcode from the App Store and run: xcode-select --install"
        exit 1
    fi
    
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_status "Xcode: $XCODE_VERSION ✓"
    
    # Check iOS Simulator
    if ! xcrun simctl list devices | grep -q "iPhone"; then
        print_error "No iOS simulators found"
        print_error "Please open Xcode and install iOS simulators"
        exit 1
    fi
    
    print_status "iOS Simulators available ✓"
}

# Fix app name in pubspec.yaml
fix_pubspec() {
    print_header "📝 Updating pubspec.yaml..."
    
    cd "$PROJECT_DIR"
    
    # Update the name in pubspec.yaml
    if grep -q "name: agricultural_platform" pubspec.yaml; then
        sed -i '' 's/name: agricultural_platform/name: agrivision/' pubspec.yaml
        print_status "Updated package name in pubspec.yaml"
    fi
    
    # Update description
    if grep -q "description: Agricultural Intelligence Platform" pubspec.yaml; then
        sed -i '' 's/description: Agricultural Intelligence Platform for East African farmers/description: AgriVision - Smart Farming Platform for East Africa/' pubspec.yaml
        print_status "Updated description in pubspec.yaml"
    fi
}

# Fix iOS Info.plist
fix_ios_info_plist() {
    print_header "📱 Updating iOS Info.plist..."
    
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
    
    print_status "Updated iOS Info.plist with app name: $DISPLAY_NAME"
}

# Fix iOS project settings
fix_ios_project_settings() {
    print_header "⚙️ Updating iOS Project Settings..."
    
    cd "$PROJECT_DIR/ios"
    
    # Update product name in project.pbxproj
    if [ -f "Runner.xcodeproj/project.pbxproj" ]; then
        # Update PRODUCT_NAME
        sed -i '' "s/PRODUCT_NAME = agricultural_platform/PRODUCT_NAME = $APP_NAME/g" Runner.xcodeproj/project.pbxproj
        sed -i '' "s/PRODUCT_NAME = Runner/PRODUCT_NAME = $APP_NAME/g" Runner.xcodeproj/project.pbxproj
        
        # Update PRODUCT_BUNDLE_IDENTIFIER
        sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com.example.agriculturalPlatform/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID/g" Runner.xcodeproj/project.pbxproj
        sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com.example.agricultural_platform/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID/g" Runner.xcodeproj/project.pbxproj
        
        print_status "Updated iOS project settings"
    fi
}

# Clean build cache
clean_build_cache() {
    print_header "🧹 Cleaning Build Cache..."
    
    cd "$PROJECT_DIR"
    
    # Flutter clean
    flutter clean
    print_status "Flutter cache cleaned"
    
    # Remove iOS build directory
    if [ -d "build" ]; then
        rm -rf build
        print_status "Build directory removed"
    fi
    
    # Remove iOS derived data (if accessible)
    if [ -d "ios/build" ]; then
        rm -rf ios/build
        print_status "iOS build directory removed"
    fi
    
    # Clean Xcode derived data
    if [ -d "$HOME/Library/Developer/Xcode/DerivedData" ]; then
        find "$HOME/Library/Developer/Xcode/DerivedData" -name "*agricultural*" -type d -exec rm -rf {} + 2>/dev/null || true
        find "$HOME/Library/Developer/Xcode/DerivedData" -name "*AgriVision*" -type d -exec rm -rf {} + 2>/dev/null || true
        print_status "Xcode derived data cleaned"
    fi
}

# Get Flutter dependencies
get_dependencies() {
    print_header "📦 Getting Flutter Dependencies..."
    
    cd "$PROJECT_DIR"
    flutter pub get
    print_status "Flutter dependencies updated"
}

# Generate iOS project files
generate_ios_files() {
    print_header "🔧 Generating iOS Project Files..."
    
    cd "$PROJECT_DIR"
    
    # Generate iOS project
    flutter create --org com.agrivision --project-name agrivision --platforms ios .
    print_status "iOS project files regenerated"
    
    # Re-apply our custom settings
    fix_ios_info_plist
    fix_ios_project_settings
}

# List available simulators
list_simulators() {
    print_header "📱 Available iOS Simulators:"
    xcrun simctl list devices available | grep iPhone | head -10
}

# Launch on simulator
launch_simulator() {
    print_header "🚀 Launching AgriVision on iOS Simulator..."
    
    cd "$PROJECT_DIR"
    
    # Get the first available iPhone simulator
    SIMULATOR_ID=$(xcrun simctl list devices available | grep iPhone | head -1 | grep -o '[A-F0-9-]\{36\}')
    
    if [ -z "$SIMULATOR_ID" ]; then
        print_error "No iPhone simulator found"
        print_error "Please open Xcode and create an iPhone simulator"
        exit 1
    fi
    
    SIMULATOR_NAME=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | sed 's/.*(\([^)]*\)).*/\1/')
    print_status "Using simulator: $SIMULATOR_NAME"
    
    # Boot simulator if not already running
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
    
    # Wait for simulator to boot
    print_status "Waiting for simulator to boot..."
    sleep 3
    
    # Launch the app
    print_status "Building and launching AgriVision..."
    flutter run -d "$SIMULATOR_ID" --debug
}

# Alternative launch method using device selection
launch_with_device_selection() {
    print_header "🚀 Launching AgriVision with Device Selection..."
    
    cd "$PROJECT_DIR"
    
    print_status "Available devices:"
    flutter devices
    
    print_status "Launching on iOS simulator..."
    flutter run --debug
}

# Verify app name fix
verify_fix() {
    print_header "✅ Verifying App Name Fix..."
    
    INFO_PLIST="$PROJECT_DIR/ios/Runner/Info.plist"
    
    DISPLAY_NAME_CHECK=$(/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "$INFO_PLIST" 2>/dev/null || echo "Not set")
    BUNDLE_NAME_CHECK=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$INFO_PLIST" 2>/dev/null || echo "Not set")
    
    print_status "CFBundleDisplayName: $DISPLAY_NAME_CHECK"
    print_status "CFBundleName: $BUNDLE_NAME_CHECK"
    
    if [ "$DISPLAY_NAME_CHECK" = "$DISPLAY_NAME" ]; then
        print_success "✅ App display name correctly set to: $DISPLAY_NAME"
    else
        print_warning "⚠️ App display name may not be set correctly"
    fi
}

# Create app icon (basic)
create_app_icon() {
    print_header "🎨 Setting up App Icon..."
    
    ASSETS_DIR="$PROJECT_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    
    if [ -d "$ASSETS_DIR" ]; then
        print_status "App icon assets directory exists"
        
        # Create a simple Contents.json if it doesn't exist
        if [ ! -f "$ASSETS_DIR/Contents.json" ]; then
            cat > "$ASSETS_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
            print_status "Created app icon configuration"
        fi
    fi
}

# Main execution
main() {
    print_header "🌾 AgriVision iOS App Name Fix & Launch Script"
    print_header "=============================================="
    echo ""
    
    # Check prerequisites
    check_directory
    check_prerequisites
    
    # Ask user what they want to do
    echo ""
    print_header "What would you like to do?"
    echo "1. Fix app name and launch on simulator"
    echo "2. Just fix app name (no launch)"
    echo "3. Just launch on simulator (no fixes)"
    echo "4. Full reset and fix (recommended for persistent issues)"
    echo ""
    read -p "Enter your choice (1-4): " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            print_header "🔧 Fixing app name and launching..."
            fix_pubspec
            fix_ios_info_plist
            fix_ios_project_settings
            create_app_icon
            clean_build_cache
            get_dependencies
            verify_fix
            launch_with_device_selection
            ;;
        2)
            print_header "🔧 Fixing app name only..."
            fix_pubspec
            fix_ios_info_plist
            fix_ios_project_settings
            create_app_icon
            verify_fix
            print_success "✅ App name fixed! Run the script again with option 3 to launch."
            ;;
        3)
            print_header "🚀 Launching on simulator..."
            list_simulators
            launch_with_device_selection
            ;;
        4)
            print_header "🔄 Full reset and fix..."
            fix_pubspec
            clean_build_cache
            generate_ios_files
            create_app_icon
            get_dependencies
            verify_fix
            launch_with_device_selection
            ;;
        *)
            print_error "Invalid choice. Please run the script again."
            exit 1
            ;;
    esac
    
    echo ""
    print_success "🎉 Done!"
    echo ""
    print_header "📋 Troubleshooting Tips:"
    echo "• If the app name still doesn't change, try option 4 (full reset)"
    echo "• Make sure to completely close and reopen the iOS Simulator"
    echo "• If issues persist, delete the app from simulator and reinstall"
    echo "• Check Xcode for any build errors"
    echo ""
    print_header "🔧 Manual Steps (if needed):"
    echo "1. Open ios/Runner.xcworkspace in Xcode"
    echo "2. Select Runner target → General → Display Name"
    echo "3. Change to 'AgriVision'"
    echo "4. Clean build folder (Cmd+Shift+K)"
    echo "5. Build and run (Cmd+R)"
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi