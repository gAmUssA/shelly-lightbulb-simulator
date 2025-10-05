.PHONY: help install build clean dev backend frontend test test-backend test-frontend build-backend build-frontend docker-build docker-run docker-stop docker-push docker-clean kong-config kong-logs

# Default target
help:
	@echo "Shelly Lightbulb Simulator - Available Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make install          - Install all dependencies (backend + frontend)"
	@echo ""
	@echo "Development:"
	@echo "  make dev              - Run both backend and frontend (requires 2 terminals)"
	@echo "  make backend          - Run backend server on port 8080"
	@echo "  make frontend         - Run frontend dev server on port 3000"
	@echo ""
	@echo "Build:"
	@echo "  make build            - Build both backend and frontend"
	@echo "  make build-backend    - Build backend only"
	@echo "  make build-frontend   - Build frontend for production"
	@echo ""
	@echo "Testing:"
	@echo "  make test             - Run all tests (backend + frontend)"
	@echo "  make test-backend     - Run backend tests"
	@echo "  make test-frontend    - Run frontend tests"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean            - Clean all build artifacts"
	@echo ""
	@echo "Docker:"
	@echo "  make docker-build     - Build Docker images"
	@echo "  make docker-run       - Start application with docker-compose"
	@echo "  make docker-stop      - Stop Docker containers"
	@echo "  make docker-push      - Push images to Docker Hub"
	@echo "  make docker-clean     - Remove containers and images"
	@echo "  make kong-config      - Validate Kong configuration"
	@echo "  make kong-logs        - View Kong logs"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make install       - First time setup"
	@echo "  2. make dev           - Start development (run in 2 terminals)"
	@echo "  OR"
	@echo "  1. make docker-build  - Build Docker images"
	@echo "  2. make docker-run    - Run with Docker"
	@echo ""

# Install all dependencies
install: install-backend install-frontend
	@echo "✓ All dependencies installed"

install-backend:
	@echo "Installing backend dependencies..."
	@cd backend && ./gradlew build -x test

install-frontend:
	@echo "Installing frontend dependencies..."
	@cd frontend && npm install

# Development servers
dev:
	@echo "Starting development servers..."
	@echo "Run these commands in separate terminals:"
	@echo "  Terminal 1: make backend"
	@echo "  Terminal 2: make frontend"

backend:
	@echo "Starting backend on http://localhost:8080"
	@cd backend && ./gradlew bootRun

frontend:
	@echo "Starting frontend on http://localhost:3000"
	@cd frontend && npm run dev

# Build for production
build: build-backend build-frontend
	@echo "✓ Build complete"

build-backend:
	@echo "Building backend..."
	@cd backend && ./gradlew build

build-frontend:
	@echo "Building frontend..."
	@cd frontend && npm run build

# Testing
test: test-backend test-frontend
	@echo "✓ All tests passed"

test-backend:
	@echo "Running backend tests..."
	@cd backend && ./gradlew test

test-frontend:
	@echo "Running frontend tests..."
	@cd frontend && npm test

# Clean build artifacts
clean: clean-backend clean-frontend
	@echo "✓ Cleaned all build artifacts"

clean-backend:
	@echo "Cleaning backend..."
	@cd backend && ./gradlew clean

clean-frontend:
	@echo "Cleaning frontend..."
	@cd frontend && rm -rf dist node_modules/.vite

# Preview production build
preview-frontend:
	@echo "Previewing production build..."
	@cd frontend && npm run preview

# Check versions
check:
	@echo "Checking prerequisites..."
	@echo -n "Java version: "
	@java -version 2>&1 | head -n 1
	@echo -n "Node version: "
	@node -v
	@echo -n "npm version: "
	@npm -v
	@echo "✓ Prerequisites check complete"

# Docker targets
docker-build:
	@echo "Building Docker images..."
	@./docker-build.sh
	@echo "✓ Docker images built successfully"

docker-run:
	@echo "Starting application with docker-compose..."
	@docker-compose up -d
	@echo "✓ Application started"
	@echo ""
	@echo "Services available at:"
	@echo "  Kong Gateway (Proxy): http://localhost:8000"
	@echo "  Kong Admin API:       http://localhost:8001"
	@echo "  Frontend:             http://localhost:8000/"
	@echo "  Backend API:          http://localhost:8000/api"
	@echo "  GraphQL:              http://localhost:8000/graphql"
	@echo ""
	@echo "View logs with: docker-compose logs -f"

docker-stop:
	@echo "Stopping Docker containers..."
	@docker-compose down
	@echo "✓ Containers stopped"

docker-push:
	@echo "Pushing images to Docker Hub..."
	@./docker-push.sh
	@echo "✓ Images pushed successfully"

docker-clean:
	@echo "Cleaning Docker containers and images..."
	@docker-compose down -v
	@docker rmi shelly-simulator-backend:latest shelly-simulator-frontend:latest 2>/dev/null || true
	@echo "✓ Docker cleanup complete"

kong-config:
	@echo "Validating Kong configuration..."
	@docker run --rm -v $(PWD)/kong.yml:/tmp/kong.yml kong:latest kong config parse /tmp/kong.yml
	@echo "✓ Kong configuration is valid"

kong-logs:
	@echo "Viewing Kong logs (Ctrl+C to exit)..."
	@docker-compose logs -f kong
