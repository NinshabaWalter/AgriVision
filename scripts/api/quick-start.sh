#!/bin/bash

# Agricultural Intelligence Platform - Quick Start Script
# This script helps you get the platform running quickly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check Docker
    if ! command_exists docker; then
        missing_deps+=("docker")
    fi
    
    # Check Docker Compose
    if ! command_exists docker-compose; then
        missing_deps+=("docker-compose")
    fi
    
    # Check Python (for backend development)
    if ! command_exists python3; then
        missing_deps+=("python3")
    fi
    
    # Check Flutter (for mobile development)
    if ! command_exists flutter; then
        missing_deps+=("flutter")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Please install the missing dependencies and run this script again."
        print_status "Installation guides:"
        print_status "- Docker: https://docs.docker.com/get-docker/"
        print_status "- Docker Compose: https://docs.docker.com/compose/install/"
        print_status "- Python: https://www.python.org/downloads/"
        print_status "- Flutter: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    print_success "All prerequisites are installed!"
}

# Function to setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    # Copy environment file if it doesn't exist
    if [ ! -f .env ]; then
        cp .env.example .env
        print_success "Created .env file from template"
        print_warning "Please edit .env file with your API keys and configuration"
        print_status "Required API keys:"
        print_status "- OPENWEATHER_API_KEY: Get from https://openweathermap.org/api"
        print_status "- TWILIO_ACCOUNT_SID & TWILIO_AUTH_TOKEN: Get from https://www.twilio.com/"
        print_status "- FIREBASE_SERVER_KEY: Get from Firebase Console"
    else
        print_status ".env file already exists"
    fi
}

# Function to start backend services
start_backend() {
    print_status "Starting backend services with Docker Compose..."
    
    # Start PostgreSQL and Redis first
    docker-compose up -d postgres redis
    
    # Wait for databases to be ready
    print_status "Waiting for databases to be ready..."
    sleep 10
    
    # Start backend service
    docker-compose up -d backend
    
    # Wait for backend to be ready
    print_status "Waiting for backend to be ready..."
    sleep 15
    
    # Check if backend is running
    if curl -f http://localhost:8000/health >/dev/null 2>&1; then
        print_success "Backend is running at http://localhost:8000"
        print_status "API documentation available at http://localhost:8000/docs"
    else
        print_error "Backend failed to start. Check logs with: docker-compose logs backend"
        return 1
    fi
}

# Function to setup mobile app
setup_mobile() {
    print_status "Setting up mobile application..."
    
    cd mobile
    
    # Get Flutter dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Generate code
    print_status "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    print_success "Mobile app setup complete!"
    print_status "To run the mobile app:"
    print_status "  cd mobile"
    print_status "  flutter run"
    
    cd ..
}

# Function to start monitoring services
start_monitoring() {
    print_status "Starting monitoring services..."
    
    # Start Prometheus and Grafana
    docker-compose up -d prometheus grafana
    
    print_success "Monitoring services started!"
    print_status "Grafana dashboard: http://localhost:3000 (admin/admin)"
    print_status "Prometheus: http://localhost:9090"
}

# Function to run database migrations
run_migrations() {
    print_status "Running database migrations..."
    
    # Run migrations in backend container
    docker-compose exec backend alembic upgrade head
    
    print_success "Database migrations completed!"
}

# Function to load sample data
load_sample_data() {
    print_status "Loading sample data..."
    
    # Check if sample data script exists
    if [ -f "scripts/load_sample_data.py" ]; then
        docker-compose exec backend python scripts/load_sample_data.py
        print_success "Sample data loaded!"
    else
        print_warning "Sample data script not found, skipping..."
    fi
}

# Function to show status
show_status() {
    print_status "Checking service status..."
    
    echo ""
    print_status "Docker containers:"
    docker-compose ps
    
    echo ""
    print_status "Service URLs:"
    print_status "- Backend API: http://localhost:8000"
    print_status "- API Documentation: http://localhost:8000/docs"
    print_status "- Grafana Dashboard: http://localhost:3000"
    print_status "- Prometheus: http://localhost:9090"
    
    echo ""
    print_status "To run mobile app:"
    print_status "  cd mobile && flutter run"
    
    echo ""
    print_status "Useful commands:"
    print_status "- View logs: docker-compose logs -f [service-name]"
    print_status "- Stop services: docker-compose down"
    print_status "- Restart services: docker-compose restart [service-name]"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up..."
    docker-compose down
    print_success "Services stopped!"
}

# Main menu
show_menu() {
    echo ""
    echo "🌾 Agricultural Intelligence Platform - Quick Start"
    echo "=================================================="
    echo ""
    echo "1. Full Setup (Recommended for first time)"
    echo "2. Start Backend Services Only"
    echo "3. Setup Mobile App Only"
    echo "4. Start Monitoring Services"
    echo "5. Run Database Migrations"
    echo "6. Load Sample Data"
    echo "7. Show Service Status"
    echo "8. Stop All Services"
    echo "9. Exit"
    echo ""
}

# Main function
main() {
    echo "🌾 Welcome to Agricultural Intelligence Platform Quick Start!"
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "docker-compose.yml" ]; then
        print_error "Please run this script from the AgriculturalIntelligencePlatform directory"
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Please select an option (1-9): " choice
        
        case $choice in
            1)
                check_prerequisites
                setup_environment
                start_backend
                run_migrations
                load_sample_data
                setup_mobile
                start_monitoring
                show_status
                print_success "Full setup completed! 🎉"
                ;;
            2)
                check_prerequisites
                setup_environment
                start_backend
                ;;
            3)
                setup_mobile
                ;;
            4)
                start_monitoring
                ;;
            5)
                run_migrations
                ;;
            6)
                load_sample_data
                ;;
            7)
                show_status
                ;;
            8)
                cleanup
                ;;
            9)
                print_status "Goodbye! 👋"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-9."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Handle Ctrl+C
trap cleanup INT

# Run main function
main