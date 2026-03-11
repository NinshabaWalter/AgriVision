#!/bin/bash

# AgriVision Enhanced API Gateway Startup Script
# This script helps you get started with the enhanced API gateway

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check if Node.js is installed
check_nodejs() {
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 16+ from https://nodejs.org/"
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 16 ]; then
        print_error "Node.js version 16+ is required. Current version: $(node --version)"
        exit 1
    fi
    
    print_status "Node.js version: $(node --version) ✓"
}

# Check if npm is installed
check_npm() {
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install npm."
        exit 1
    fi
    
    print_status "npm version: $(npm --version) ✓"
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    if [ ! -f "package.json" ]; then
        print_error "package.json not found. Are you in the correct directory?"
        exit 1
    fi
    
    npm install
    print_status "Dependencies installed successfully ✓"
}

# Setup environment file
setup_environment() {
    print_status "Setting up environment configuration..."
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.enhanced" ]; then
            cp .env.enhanced .env
            print_status "Created .env file from .env.enhanced template"
        else
            print_error ".env.enhanced template not found"
            exit 1
        fi
    else
        print_warning ".env file already exists, skipping creation"
    fi
    
    print_warning "Please edit .env file with your actual API keys and configuration"
    print_warning "Key services to configure:"
    echo "  - TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN for SMS"
    echo "  - MPESA_CONSUMER_KEY and MPESA_CONSUMER_SECRET for payments"
    echo "  - HUGGINGFACE_API_KEY for AI features"
    echo "  - JWT_SECRET for authentication (change the default!)"
}

# Create logs directory
setup_logging() {
    print_status "Setting up logging directory..."
    
    if [ ! -d "logs" ]; then
        mkdir logs
        print_status "Created logs directory ✓"
    else
        print_status "Logs directory already exists ✓"
    fi
}

# Run tests
run_tests() {
    print_status "Running API tests..."
    
    # Start the server in background
    print_status "Starting API server for testing..."
    npm start &
    SERVER_PID=$!
    
    # Wait for server to start
    sleep 5
    
    # Run tests
    if node test-enhanced-api.js; then
        print_status "All tests passed! ✓"
    else
        print_warning "Some tests failed. Check the output above."
    fi
    
    # Stop the server
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
}

# Display startup information
show_startup_info() {
    print_header "🌾 AgriVision Enhanced API Gateway"
    print_header "=================================="
    echo ""
    print_status "Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Edit .env file with your API keys"
    echo "2. Start the server: npm start"
    echo "3. Test the API: node test-enhanced-api.js"
    echo ""
    echo "Available commands:"
    echo "  npm start          - Start production server"
    echo "  npm run dev        - Start development server with auto-reload"
    echo "  npm test           - Run test suite"
    echo "  npm run lint       - Check code style"
    echo ""
    echo "API will be available at: http://localhost:3000"
    echo "Health check: http://localhost:3000/health"
    echo ""
    print_header "Documentation: README-ENHANCED-API.md"
}

# Main execution
main() {
    print_header "🚀 Setting up AgriVision Enhanced API Gateway..."
    echo ""
    
    # Check prerequisites
    check_nodejs
    check_npm
    
    # Setup
    install_dependencies
    setup_environment
    setup_logging
    
    # Ask if user wants to run tests
    echo ""
    read -p "Do you want to run the test suite now? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_tests
    else
        print_status "Skipping tests. You can run them later with: node test-enhanced-api.js"
    fi
    
    echo ""
    show_startup_info
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi