#!/bin/bash

# Docker Build Script for Shelly Lightbulb Simulator
# Builds backend and frontend Docker images with version tags

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
VERSION="${VERSION:-1.0.0}"
REGISTRY="${REGISTRY:-gamussa}"
REPOSITORY="${REPOSITORY:-shelly-simulator}"

# Image names
BACKEND_IMAGE="${REGISTRY:+$REGISTRY/}${REPOSITORY}-backend"
FRONTEND_IMAGE="${REGISTRY:+$REGISTRY/}${REPOSITORY}-frontend"

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to validate Docker is installed and running
validate_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    
    print_info "Docker validation passed"
}

# Function to validate required files exist
validate_files() {
    if [ ! -f "backend/Dockerfile" ]; then
        print_error "backend/Dockerfile not found"
        exit 1
    fi
    
    if [ ! -f "frontend/Dockerfile" ]; then
        print_error "frontend/Dockerfile not found"
        exit 1
    fi
    
    print_info "Required Dockerfiles found"
}

# Function to build backend image
build_backend() {
    print_info "Building backend image..."
    print_info "Image: ${BACKEND_IMAGE}:${VERSION}"
    
    if docker build -t "${BACKEND_IMAGE}:${VERSION}" ./backend; then
        print_info "Backend image built successfully"
        
        # Tag with 'latest'
        docker tag "${BACKEND_IMAGE}:${VERSION}" "${BACKEND_IMAGE}:latest"
        print_info "Tagged backend image as 'latest'"
    else
        print_error "Failed to build backend image"
        exit 1
    fi
}

# Function to build frontend image
build_frontend() {
    print_info "Building frontend image..."
    print_info "Image: ${FRONTEND_IMAGE}:${VERSION}"
    
    if docker build -t "${FRONTEND_IMAGE}:${VERSION}" ./frontend; then
        print_info "Frontend image built successfully"
        
        # Tag with 'latest'
        docker tag "${FRONTEND_IMAGE}:${VERSION}" "${FRONTEND_IMAGE}:latest"
        print_info "Tagged frontend image as 'latest'"
    else
        print_error "Failed to build frontend image"
        exit 1
    fi
}

# Function to display build summary
display_summary() {
    echo ""
    print_info "========================================="
    print_info "Build Summary"
    print_info "========================================="
    print_info "Backend Images:"
    print_info "  - ${BACKEND_IMAGE}:${VERSION}"
    print_info "  - ${BACKEND_IMAGE}:latest"
    print_info ""
    print_info "Frontend Images:"
    print_info "  - ${FRONTEND_IMAGE}:${VERSION}"
    print_info "  - ${FRONTEND_IMAGE}:latest"
    print_info "========================================="
    echo ""
    
    # Display image sizes
    print_info "Image Sizes:"
    docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | grep "${REPOSITORY}"
}

# Main execution
main() {
    print_info "Starting Docker build process..."
    print_info "Version: ${VERSION}"
    print_info "Registry: ${REGISTRY:-<none>}"
    print_info "Repository: ${REPOSITORY}"
    echo ""
    
    # Validate environment
    validate_docker
    validate_files
    
    echo ""
    
    # Build images
    build_backend
    echo ""
    build_frontend
    
    # Display summary
    display_summary
    
    print_info "Build completed successfully!"
}

# Run main function
main
