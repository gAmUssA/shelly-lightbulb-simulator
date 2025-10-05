# Design Document

## Overview

The Docker containerization solution will package the Shelly Lightbulb Simulator as distributable Docker images. The design uses multi-stage builds for optimal image sizes, docker-compose for orchestration, and follows best practices for security and performance. The solution supports both local development and production deployment scenarios.

## Architecture

### Container Architecture

```
┌──────────────────────────────────────────────┐
│          Docker Compose Stack                │
├──────────────────────────────────────────────┤
│                                              │
│  ┌──────────────┐    ┌──────────────┐       │
│  │   Frontend   │    │   Backend    │       │
│  │   (nginx)    │    │  (Spring)    │       │
│  │   Port 80    │    │  Port 8080   │       │
│  └──────┬───────┘    └──────┬───────┘       │
│         │                   │                │
│         └───────┬───────────┘                │
│                 │                            │
│         ┌───────▼────────┐                   │
│         │  Kong Gateway  │                   │
│         │   Port 8000    │                   │
│         │   Admin: 8001  │                   │
│         └────────────────┘                   │
│                 │                            │
└─────────────────┼────────────────────────────┘
                  │
                  ▼
            Host: 8000
```

### Multi-Stage Build Strategy

**Backend (Kotlin/Spring Boot):**
- Stage 1: Build stage using gradle:8.5-jdk21 - compiles the application
- Stage 2: Runtime stage using eclipse-temurin:21-jre-alpine - runs the JAR

**Frontend (Preact/Vite):**
- Stage 1: Build stage using node:20-alpine - builds static assets
- Stage 2: Runtime stage using nginx:alpine - serves static files

**Kong API Gateway:**
- Official Kong image (kong:latest)
- DB-less mode (no database required)
- Declarative configuration via kong.yml

## Components and Interfaces

### 1. Backend Dockerfile

**Location:** `backend/Dockerfile`

**Build Stages:**
```dockerfile
# Stage 1: Build
FROM gradle:8.5-jdk21 AS builder
- Copy source code
- Run gradle build
- Output: JAR file in build/libs/

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-alpine
- Copy JAR from builder stage
- Create non-root user
- Expose port 8080
- Run application
```

**Key Features:**
- Layer caching optimization (copy gradle files before source)
- Non-root user for security
- Health check support
- Minimal runtime image (JRE only)

### 2. Frontend Dockerfile

**Location:** `frontend/Dockerfile`

**Build Stages:**
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
- Copy package files
- Install dependencies
- Copy source code
- Run npm build
- Output: dist/ directory

# Stage 2: Runtime
FROM nginx:alpine
- Copy built assets from builder
- Copy custom nginx configuration
- Expose port 80
- Run nginx
```

**Key Features:**
- Optimized npm install with package.json caching
- Custom nginx config for SPA routing
- Gzip compression enabled
- Security headers configured

### 3. Docker Compose Configuration

**Location:** `docker-compose.yml`

**Services:**

```yaml
services:
  kong:
    image: kong:latest
    ports: 
      - 8000:8000  # Proxy
      - 8001:8001  # Admin API
    environment:
      - KONG_DATABASE=off
      - KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml
      - KONG_PROXY_ACCESS_LOG=/dev/stdout
      - KONG_ADMIN_ACCESS_LOG=/dev/stdout
      - KONG_PROXY_ERROR_LOG=/dev/stderr
      - KONG_ADMIN_ERROR_LOG=/dev/stderr
      - KONG_ADMIN_LISTEN=0.0.0.0:8001
    volumes:
      - ./kong.yml:/usr/local/kong/declarative/kong.yml
    depends_on:
      - backend
      - frontend
    
  backend:
    build: ./backend
    environment:
      - SPRING_PROFILES_ACTIVE=docker
    healthcheck: /actuator/health
    
  frontend:
    build: ./frontend
```

**Network Configuration:**
- Default bridge network for inter-container communication
- Kong acts as API gateway routing traffic to backend and frontend
- Only Kong ports exposed to host (8000 for proxy, 8001 for admin)
- Backend and frontend communicate internally

### 4. Kong Configuration

**Location:** `kong.yml`

**Declarative Configuration:**
```yaml
_format_version: "3.0"

services:
  - name: backend-service
    url: http://backend:8080
    routes:
      - name: api-route
        paths:
          - /api
        strip_path: true
      - name: graphql-route
        paths:
          - /graphql
        strip_path: false
    plugins:
      - name: cors
        config:
          origins:
            - "*"
          methods:
            - GET
            - POST
            - PUT
            - DELETE
            - OPTIONS
          headers:
            - Accept
            - Content-Type
            - Authorization
          exposed_headers:
            - X-Auth-Token
          credentials: true
          max_age: 3600
      - name: rate-limiting
        config:
          minute: 100
          policy: local

  - name: frontend-service
    url: http://frontend:80
    routes:
      - name: frontend-route
        paths:
          - /
        strip_path: false
```

**Key Features:**
- Routes API calls to backend service
- Routes frontend requests to nginx container
- CORS plugin for cross-origin support
- Rate limiting for API protection
- WebSocket support for GraphQL subscriptions
- Request/response logging
- Health checks for upstream services

### 5. Nginx Configuration (Frontend)

**Location:** `frontend/nginx.conf`

**Configuration:**
```nginx
server {
  listen 80;
  root /usr/share/nginx/html;
  
  # SPA routing
  location / {
    try_files $uri $uri/ /index.html;
  }
  
  # Health check endpoint
  location /health {
    access_log off;
    return 200 "healthy\n";
    add_header Content-Type text/plain;
  }
}
```

### 6. Build and Push Scripts

**Location:** `docker-build.sh` and `docker-push.sh`

**Build Script:**
- Builds both images with version tags
- Tags with 'latest'
- Supports custom registry/repository names

**Push Script:**
- Authenticates with Docker Hub
- Pushes version and latest tags
- Validates successful push

## Data Models

### Environment Variables

**Backend:**
```
SPRING_PROFILES_ACTIVE=docker
SERVER_PORT=8080
CORS_ALLOWED_ORIGINS=*
```

**Frontend:**
```
VITE_API_BASE_URL=/api
VITE_GRAPHQL_WS_URL=ws://localhost:8000/graphql
```

**Kong:**
```
KONG_DATABASE=off
KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml
KONG_PROXY_ACCESS_LOG=/dev/stdout
KONG_ADMIN_ACCESS_LOG=/dev/stdout
KONG_PROXY_ERROR_LOG=/dev/stderr
KONG_ADMIN_ERROR_LOG=/dev/stderr
```

### Docker Image Tags

```
Format: <registry>/<repository>/<image>:<tag>

Examples:
- username/shelly-simulator-backend:1.0.0
- username/shelly-simulator-backend:latest
- username/shelly-simulator-frontend:1.0.0
- username/shelly-simulator-frontend:latest

Note: Kong uses official kong:latest image, no custom build needed
```

## Error Handling

### Build Failures

**Gradle Build Errors:**
- Fail fast with clear error messages
- Cache gradle dependencies to speed up retries
- Log full build output for debugging

**NPM Build Errors:**
- Display npm error logs
- Validate node_modules installation
- Check for missing dependencies

### Runtime Failures

**Container Startup:**
- Health checks to verify service availability
- Restart policies (on-failure with max retries)
- Logging to stdout/stderr for docker logs

**Network Issues:**
- Frontend proxy fallback configuration
- Backend connection retry logic
- Clear error messages for connection failures

### Docker Hub Push Failures

**Authentication:**
- Validate Docker Hub credentials before push
- Provide clear login instructions
- Support token-based authentication

**Network/Upload:**
- Retry logic for transient failures
- Progress indicators for large uploads
- Validation of successful push

## Testing Strategy

### Local Testing

**Build Verification:**
1. Build both images locally
2. Verify image sizes are reasonable (<500MB backend, <50MB frontend)
3. Check for security vulnerabilities with docker scan

**Runtime Testing:**
1. Start containers with docker-compose
2. Verify Kong admin API is accessible (localhost:8001)
3. Verify Kong proxy routes requests (localhost:8000)
4. Verify backend health endpoint responds through Kong
5. Verify frontend loads in browser through Kong
6. Test API calls from frontend to backend through Kong gateway
7. Test WebSocket subscriptions work through Kong
8. Verify color changes reflect in UI
9. Test Kong rate limiting works
10. Verify CORS headers are properly set by Kong

**Integration Testing:**
1. Test all REST endpoints through frontend
2. Test GraphQL queries and mutations
3. Test real-time subscriptions
4. Verify CORS configuration works

### Docker Hub Testing

**Pull and Run:**
1. Pull images from Docker Hub
2. Run with docker-compose using pulled images
3. Verify functionality matches local build
4. Test on different platforms (Linux, macOS, Windows)

### Performance Testing

**Image Size:**
- Backend target: <400MB
- Frontend target: <30MB
- Kong uses official image (~150MB, DB-less mode)
- Verify multi-stage builds reduce size

**Startup Time:**
- Kong target: <5 seconds (DB-less mode)
- Backend target: <30 seconds
- Frontend target: <5 seconds
- Measure with docker-compose up timing

**Resource Usage:**
- Monitor CPU and memory during operation
- Ensure reasonable resource limits
- Test under load with multiple concurrent requests

## Security Considerations

### Image Security

1. Use official base images from trusted sources
2. Run containers as non-root users
3. Scan images for vulnerabilities
4. Keep base images updated
5. Minimize installed packages

### Network Security

1. Use internal Docker network for service communication
2. Only expose Kong gateway ports to host (8000, 8001)
3. Backend and frontend not directly accessible from host
4. Configure Kong CORS plugin appropriately for production
5. Use Kong rate limiting to prevent abuse
6. Use environment variables for sensitive configuration
7. Secure Kong Admin API in production (restrict access, use RBAC)

### Production Deployment

1. Use specific version tags (not 'latest') in production
2. Implement proper secrets management
3. Configure resource limits
4. Enable read-only root filesystem where possible
5. Use Docker secrets for sensitive data

## Documentation Requirements

### README Updates

Add sections for:
1. Docker prerequisites
2. Building images locally
3. Running with docker-compose
4. Pulling from Docker Hub
5. Environment variable configuration
6. Troubleshooting common issues

### Docker Hub Repository

Create repository documentation with:
1. Quick start guide
2. Available tags and versions
3. Configuration options
4. Example docker-compose.yml
5. Links to full documentation

### Makefile Integration

Add targets:
- `make docker-build` - Build images
- `make docker-run` - Run with docker-compose
- `make docker-push` - Push to Docker Hub
- `make docker-clean` - Clean up containers and images
- `make kong-config` - Validate Kong configuration
- `make kong-logs` - View Kong logs
