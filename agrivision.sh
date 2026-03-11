#!/bin/bash

# AgriVision Quick Access Script
# Navigate the organized project structure easily

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
}

show_menu() {
    clear
    print_header "🌾 AgriVision - Quick Access Menu"
    print_header "================================="
    echo ""
    print_info "📱 iOS Development:"
    echo "  1. Run iOS App (with fixes)"
    echo "  2. Diagnose iOS Issues"
    echo "  3. Check App Status"
    echo "  4. Fix iOS App Name"
    echo ""
    print_info "🌐 API Development:"
    echo "  5. Start Organized API"
    echo "  6. Start Enhanced API"
    echo "  7. Run API Tests"
    echo "  8. Quick API Setup"
    echo ""
    print_info "🐍 Backend Development:"
    echo "  9. Start Python Backend"
    echo "  10. Setup Backend Environment"
    echo ""
    print_info "📚 Documentation:"
    echo "  11. View Project Structure"
    echo "  12. Open Getting Started Guide"
    echo "  13. View API Documentation"
    echo "  14. iOS Troubleshooting Guide"
    echo ""
    print_info "🔧 Utilities:"
    echo "  15. Open Project in VS Code"
    echo "  16. Show All Available Scripts"
    echo "  17. Clean Build Caches"
    echo ""
    echo "  0. Exit"
    echo ""
    print_warning "Enter your choice (0-17): "
}

execute_choice() {
    case $1 in
        1)
            print_success "🚀 Launching iOS App..."
            ./scripts/ios/run-ios-app.sh
            ;;
        2)
            print_success "🔍 Diagnosing iOS Issues..."
            ./scripts/ios/diagnose-ios-app.sh
            ;;
        3)
            print_success "📊 Checking App Status..."
            ./scripts/ios/check-app-status.sh
            ;;
        4)
            print_success "🔧 Fixing iOS App Name..."
            ./scripts/ios/fix-ios-app-name.sh
            ;;
        5)
            print_success "🌐 Starting Organized API..."
            ./scripts/api/start-organized-api.sh
            ;;
        6)
            print_success "⚡ Starting Enhanced API..."
            ./scripts/api/start-enhanced-api.sh
            ;;
        7)
            print_success "🧪 Running API Tests..."
            npm test
            ;;
        8)
            print_success "⚡ Quick API Setup..."
            ./scripts/api/quick-start.sh
            ;;
        9)
            print_success "🐍 Starting Python Backend..."
            cd backend && python app/main.py
            ;;
        10)
            print_success "🔧 Setting up Backend Environment..."
            cd backend
            python -m venv venv
            source venv/bin/activate
            pip install -r requirements.txt
            print_success "✅ Backend environment ready!"
            ;;
        11)
            print_success "📁 Opening Project Structure..."
            if command -v code &> /dev/null; then
                code PROJECT-STRUCTURE.md
            else
                cat PROJECT-STRUCTURE.md
            fi
            ;;
        12)
            print_success "📖 Opening Getting Started Guide..."
            if command -v code &> /dev/null; then
                code docs/guides/RUN_AGRIVISION.md
            else
                cat docs/guides/RUN_AGRIVISION.md
            fi
            ;;
        13)
            print_success "🌐 Opening API Documentation..."
            if command -v code &> /dev/null; then
                code docs/api/README-ENHANCED-API.md
            else
                cat docs/api/README-ENHANCED-API.md
            fi
            ;;
        14)
            print_success "🔧 Opening iOS Troubleshooting Guide..."
            if command -v code &> /dev/null; then
                code docs/guides/iOS-APP-NAME-GUIDE.md
            else
                cat docs/guides/iOS-APP-NAME-GUIDE.md
            fi
            ;;
        15)
            print_success "💻 Opening Project in VS Code..."
            if command -v code &> /dev/null; then
                code .
            else
                print_warning "VS Code not found. Please install VS Code or open the project manually."
            fi
            ;;
        16)
            print_success "📋 Available Scripts:"
            echo ""
            print_info "iOS Scripts:"
            ls -la scripts/ios/
            echo ""
            print_info "API Scripts:"
            ls -la scripts/api/
            echo ""
            print_info "Testing Scripts:"
            ls -la scripts/testing/
            ;;
        17)
            print_success "🧹 Cleaning Build Caches..."
            # Flutter clean
            if [ -d "mobile" ]; then
                cd mobile && flutter clean && cd ..
                print_success "✅ Flutter cache cleaned"
            fi
            # Node.js clean
            if [ -f "package.json" ]; then
                rm -rf node_modules package-lock.json
                npm install
                print_success "✅ Node.js cache cleaned"
            fi
            # Python clean
            if [ -d "backend" ]; then
                find backend -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
                print_success "✅ Python cache cleaned"
            fi
            ;;
        0)
            print_success "👋 Goodbye! Happy farming with AgriVision!"
            exit 0
            ;;
        *)
            print_warning "❌ Invalid choice. Please try again."
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    read -r choice
    echo ""
    execute_choice "$choice"
    echo ""
    print_info "Press Enter to continue..."
    read -r
done