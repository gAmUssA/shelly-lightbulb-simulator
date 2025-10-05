#!/bin/bash

# Docker Push Script for Shelly Lightbulb Simulator
# Pushes backend and frontend Docker images to Docker Hub

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

# Function to check Docker Hub authentication
check_authentication() {
    print_info "Checking Docker Hub authentication..."
    
    # Check if user is logged in by attempting to get auth info
    if ! docker info | grep -q "Username:"; then
        print_warning "Not logged in to Docker Hub"
        print_info "Please log in to Docker Hub using: docker login"
        print_info ""
        
        # Prompt for login
        read -p "Would you like to log in now? (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if docker login; then
                print_info "Successfully logged in to Docker Hub"
            else
                print_error "Failed to log in to Docker Hub"
                exit 1
            fi
        else
            print_error "Docker Hub authentication required to push images"
            exit 1
        fi
    else
        print_info "Already authenticated with Docker Hub"
    fi
}

# Function to validate images exist locally
validate_images() {
    print_info "Validating local images..."
    
    local missing_images=0
    
    if ! docker image inspect "${BACKEND_IMAGE}:${VERSION}" &> /dev/null; then
        print_error "Backend image ${BACKEND_IMAGE}:${VERSION} not found locally"
        missing_images=1
    fi
    
    if ! docker image inspect "${BACKEND_IMAGE}:latest" &> /dev/null; then
        print_error "Backend image ${BACKEND_IMAGE}:latest not found locally"
        missing_images=1
    fi
    
    if ! docker image inspect "${FRONTEND_IMAGE}:${VERSION}" &> /dev/null; then
        print_error "Frontend image ${FRONTEND_IMAGE}:${VERSION} not found locally"
        missing_images=1
    fi
    
    if ! docker image inspect "${FRONTEND_IMAGE}:latest" &> /dev/null; then
        print_error "Frontend image ${FRONTEND_IMAGE}:latest not found locally"
        missing_images=1
    fi
    
    if [ $missing_images -eq 1 ]; then
        print_error "Some images are missing. Please build them first using ./docker-build.sh"
        exit 1
    fi
    
    print_info "All required images found locally"
}

# Function to push backend images
push_backend() {
    print_info "Pushing backend images to Docker Hub..."
    
    # Push version tag
    print_info "Pushing ${BACKEND_IMAGE}:${VERSION}..."
    if docker push "${BACKEND_IMAGE}:${VERSION}"; then
        print_info "Successfully pushed ${BACKEND_IMAGE}:${VERSION}"
    else
        print_error "Failed to push ${BACKEND_IMAGE}:${VERSION}"
        exit 1
    fi
    
    # Push latest tag
    print_info "Pushing ${BACKEND_IMAGE}:latest..."
    if docker push "${BACKEND_IMAGE}:latest"; then
        print_info "Successfully pushed ${BACKEND_IMAGE}:latest"
    else
        print_error "Failed to push ${BACKEND_IMAGE}:latest"
        exit 1
    fi
}

# Function to push frontend images
push_frontend() {
    print_info "Pushing frontend images to Docker Hub..."
    
    # Push version tag
    print_info "Pushing ${FRONTEND_IMAGE}:${VERSION}..."
    if docker push "${FRONTEND_IMAGE}:${VERSION}"; then
        print_info "Successfully pushed ${FRONTEND_IMAGE}:${VERSION}"
    else
        print_error "Failed to push ${FRONTEND_IMAGE}:${VERSION}"
        exit 1
    fi
    
    # Push latest tag
    print_info "Pushing ${FRONTEND_IMAGE}:latest..."
    if docker push "${FRONTEND_IMAGE}:latest"; then
        print_info "Successfully pushed ${FRONTEND_IMAGE}:latest"
    else
        print_error "Failed to push ${FRONTEND_IMAGE}:latest"
        exit 1
    fi
}

# Function to display push summary
display_summary() {
    echo ""
    print_info "========================================="
    print_info "Push Summary"
    print_info "========================================="
    print_info "Successfully pushed the following images:"
    print_info ""
    print_info "Backend Images:"
    print_info "  - ${BACKEND_IMAGE}:${VERSION}"
    print_info "  - ${BACKEND_IMAGE}:latest"
    print_info ""
    print_info "Frontend Images:"
    print_info "  - ${FRONTEND_IMAGE}:${VERSION}"
    print_info "  - ${FRONTEND_IMAGE}:latest"
    print_info "========================================="
    print_info ""
    print_info "Images are now available on Docker Hub!"
    print_info ""
    print_info "To pull and use these images:"
    print_info "  docker pull ${BACKEND_IMAGE}:${VERSION}"
    print_info "  docker pull ${FRONTEND_IMAGE}:${VERSION}"
    print_info ""
    print_info "Or use 'latest' tag:"
    print_info "  docker pull ${BACKEND_IMAGE}:latest"
    print_info "  docker pull ${FRONTEND_IMAGE}:latest"
    print_info "========================================="
}

# Main execution
main() {
    print_info "Starting Docker push process..."
    print_info "Version: ${VERSION}"
    print_info "Registry: ${REGISTRY:-<none>}"
    print_info "Repository: ${REPOSITORY}"
    echo ""
    
    # Validate environment
    validate_docker
    check_authentication
    validate_images
    
    echo ""
    
    # Push images
    push_backend
    echo ""
    push_frontend
    
    # Display summary
    display_summary
    
    print_info "Push completed successfully!"
}

# Run main function
main
