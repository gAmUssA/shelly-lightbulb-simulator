.PHONY: help install build clean dev backend frontend test test-backend test-frontend build-backend build-frontend docker-build docker-run docker-stop docker-push docker-clean kong-config kong-logs

# Colors
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
MAGENTA := \033[35m
RED := \033[31m
BOLD := \033[1m
RESET := \033[0m

# Default target
help:
	@echo "$(BOLD)$(CYAN)💡 Shelly Lightbulb Simulator - Available Commands$(RESET)"
	@echo ""
	@echo "$(BOLD)$(GREEN)📦 Setup:$(RESET)"
	@echo "  $(CYAN)make install$(RESET)          - Install all dependencies (backend + frontend)"
	@echo ""
	@echo "$(BOLD)$(YELLOW)🚀 Development:$(RESET)"
	@echo "  $(CYAN)make dev$(RESET)              - Run both backend and frontend (requires 2 terminals)"
	@echo "  $(CYAN)make backend$(RESET)          - Run backend server on port 8080"
	@echo "  $(CYAN)make frontend$(RESET)         - Run frontend dev server on port 3000"
	@echo ""
	@echo "$(BOLD)$(BLUE)🔨 Build:$(RESET)"
	@echo "  $(CYAN)make build$(RESET)            - Build both backend and frontend"
	@echo "  $(CYAN)make build-backend$(RESET)    - Build backend only"
	@echo "  $(CYAN)make build-frontend$(RESET)   - Build frontend for production"
	@echo ""
	@echo "$(BOLD)$(MAGENTA)🧪 Testing:$(RESET)"
	@echo "  $(CYAN)make test$(RESET)             - Run all tests (backend + frontend)"
	@echo "  $(CYAN)make test-backend$(RESET)     - Run backend tests"
	@echo "  $(CYAN)make test-frontend$(RESET)    - Run frontend tests"
	@echo ""
	@echo "$(BOLD)$(RED)🧹 Cleanup:$(RESET)"
	@echo "  $(CYAN)make clean$(RESET)            - Clean all build artifacts"
	@echo ""
	@echo "$(BOLD)$(BLUE)🐳 Docker:$(RESET)"
	@echo "  $(CYAN)make docker-build$(RESET)     - Build Docker images"
	@echo "  $(CYAN)make docker-run$(RESET)       - Start application with docker-compose"
	@echo "  $(CYAN)make docker-stop$(RESET)      - Stop Docker containers"
	@echo "  $(CYAN)make docker-push$(RESET)      - Push images to Docker Hub"
	@echo "  $(CYAN)make docker-clean$(RESET)     - Remove containers and images"
	@echo "  $(CYAN)make kong-config$(RESET)      - Validate Kong configuration"
	@echo "  $(CYAN)make kong-logs$(RESET)        - View Kong logs"
	@echo ""
	@echo "$(BOLD)$(GREEN)⚡ Quick Start:$(RESET)"
	@echo "  $(YELLOW)1.$(RESET) $(CYAN)make install$(RESET)       - First time setup"
	@echo "  $(YELLOW)2.$(RESET) $(CYAN)make dev$(RESET)           - Start development (run in 2 terminals)"
	@echo "  $(BOLD)OR$(RESET)"
	@echo "  $(YELLOW)1.$(RESET) $(CYAN)make docker-build$(RESET)  - Build Docker images"
	@echo "  $(YELLOW)2.$(RESET) $(CYAN)make docker-run$(RESET)    - Run with Docker"
	@echo ""

# Install all dependencies
install: install-backend install-frontend
	@echo "$(GREEN)✅ All dependencies installed$(RESET)"

install-backend:
	@echo "$(YELLOW)📦 Installing backend dependencies...$(RESET)"
	@cd backend && ./gradlew build -x test

install-frontend:
	@echo "$(YELLOW)📦 Installing frontend dependencies...$(RESET)"
	@cd frontend && npm install

# Development servers
dev:
	@echo "$(YELLOW)🚀 Starting development servers...$(RESET)"
	@echo "$(BOLD)Run these commands in separate terminals:$(RESET)"
	@echo "  $(CYAN)Terminal 1:$(RESET) make backend"
	@echo "  $(CYAN)Terminal 2:$(RESET) make frontend"

backend:
	@echo "$(GREEN)🚀 Starting backend on $(BOLD)http://localhost:8080$(RESET)"
	@cd backend && ./gradlew bootRun

frontend:
	@echo "$(GREEN)🚀 Starting frontend on $(BOLD)http://localhost:3000$(RESET)"
	@cd frontend && npm run dev

# Build for production
build: build-backend build-frontend
	@echo "$(GREEN)✅ Build complete$(RESET)"

build-backend:
	@echo "$(BLUE)🔨 Building backend...$(RESET)"
	@cd backend && ./gradlew build

build-frontend:
	@echo "$(BLUE)🔨 Building frontend...$(RESET)"
	@cd frontend && npm run build

# Testing
test: test-backend test-frontend
	@echo "$(GREEN)✅ All tests passed$(RESET)"

test-backend:
	@echo "$(MAGENTA)🧪 Running backend tests...$(RESET)"
	@cd backend && ./gradlew test

test-frontend:
	@echo "$(MAGENTA)🧪 Running frontend tests...$(RESET)"
	@cd frontend && npm test

# Clean build artifacts
clean: clean-backend clean-frontend
	@echo "$(GREEN)✅ Cleaned all build artifacts$(RESET)"

clean-backend:
	@echo "$(RED)🧹 Cleaning backend...$(RESET)"
	@cd backend && ./gradlew clean

clean-frontend:
	@echo "$(RED)🧹 Cleaning frontend...$(RESET)"
	@cd frontend && rm -rf dist node_modules/.vite

# Preview production build
preview-frontend:
	@echo "$(BLUE)👀 Previewing production build...$(RESET)"
	@cd frontend && npm run preview

# Check versions
check:
	@echo "$(YELLOW)🔍 Checking prerequisites...$(RESET)"
	@echo -n "$(CYAN)Java version:$(RESET) "
	@java -version 2>&1 | head -n 1
	@echo -n "$(CYAN)Node version:$(RESET) "
	@node -v
	@echo -n "$(CYAN)npm version:$(RESET) "
	@npm -v
	@echo "$(GREEN)✅ Prerequisites check complete$(RESET)"

# Docker targets
docker-build:
	@echo "$(BLUE)🐳 Building Docker images...$(RESET)"
	@./docker-build.sh
	@echo "$(GREEN)✅ Docker images built successfully$(RESET)"

docker-run:
	@echo "$(BLUE)🐳 Starting application with docker-compose...$(RESET)"
	@docker-compose up -d
	@echo "$(GREEN)✅ Application started$(RESET)"
	@echo ""
	@echo "$(BOLD)$(CYAN)🌐 Services available at:$(RESET)"
	@echo "  $(YELLOW)Kong Gateway (Proxy):$(RESET) $(BOLD)http://localhost:8000$(RESET)"
	@echo "  $(YELLOW)Kong Admin API:$(RESET)       $(BOLD)http://localhost:8001$(RESET)"
	@echo "  $(YELLOW)Frontend:$(RESET)             $(BOLD)http://localhost:8000/$(RESET)"
	@echo "  $(YELLOW)Backend API:$(RESET)          $(BOLD)http://localhost:8000/api$(RESET)"
	@echo "  $(YELLOW)GraphQL:$(RESET)              $(BOLD)http://localhost:8000/graphql$(RESET)"
	@echo ""
	@echo "$(CYAN)📋 View logs with:$(RESET) docker-compose logs -f"

docker-stop:
	@echo "$(RED)🛑 Stopping Docker containers...$(RESET)"
	@docker-compose down
	@echo "$(GREEN)✅ Containers stopped$(RESET)"

docker-push:
	@echo "$(BLUE)📤 Pushing images to Docker Hub...$(RESET)"
	@./docker-push.sh
	@echo "$(GREEN)✅ Images pushed successfully$(RESET)"

docker-clean:
	@echo "$(RED)🧹 Cleaning Docker containers and images...$(RESET)"
	@docker-compose down -v
	@docker rmi shelly-simulator-backend:latest shelly-simulator-frontend:latest 2>/dev/null || true
	@echo "$(GREEN)✅ Docker cleanup complete$(RESET)"

kong-config:
	@echo "$(YELLOW)🔍 Validating Kong configuration...$(RESET)"
	@docker run --rm -v $(PWD)/kong.yml:/tmp/kong.yml kong:latest kong config parse /tmp/kong.yml
	@echo "$(GREEN)✅ Kong configuration is valid$(RESET)"

kong-logs:
	@echo "$(CYAN)📋 Viewing Kong logs (Ctrl+C to exit)...$(RESET)"
	@docker-compose logs -f kong
