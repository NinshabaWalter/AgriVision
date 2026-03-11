#!/bin/bash

# AgriVision API Gateway Startup Script
# This script sets up and starts the API gateway with all dependencies

echo "🌾 Starting AgriVision API Gateway..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 16+ first."
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Node.js version 16+ required. Current version: $(node -v)"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your actual API keys before running in production"
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "❌ package.json not found. Please run this script from the project root directory."
    exit 1
fi

# Start the API gateway
echo "🚀 Starting API Gateway..."
echo "📡 Server will be available at: http://localhost:3000"
echo "🔍 Health check: http://localhost:3000/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Run in development mode with auto-restart
if command -v nodemon &> /dev/null; then
    nodemon api-gateway.js
else
    echo "💡 Tip: Install nodemon for auto-restart: npm install -g nodemon"
    node api-gateway.js
fi