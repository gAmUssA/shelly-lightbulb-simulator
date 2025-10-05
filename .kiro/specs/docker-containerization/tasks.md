# Implementation Plan

- [x] 1. Create backend Dockerfile with multi-stage build

  - Create `backend/Dockerfile` with build and runtime stages
  - Use gradle:8.5-jdk21 for build stage
  - Use eclipse-temurin:21-jre-alpine for runtime stage
  - Configure non-root user for security
  - Optimize layer caching by copying gradle files before source
  - Expose port 8080
  - _Requirements: 1.1, 1.2, 1.3, 5.5_

- [x] 2. Create frontend Dockerfile with multi-stage build

  - Create `frontend/Dockerfile` with build and runtime stages
  - Use node:20-alpine for build stage
  - Use nginx:alpine for runtime stage
  - Copy package.json and package-lock.json first for caching
  - Build production assets with npm run build
  - Expose port 80
  - _Requirements: 1.1, 1.2, 1.3, 5.5_

- [x] 3. Create nginx configuration for frontend

  - Create `frontend/nginx.conf` with SPA routing support
  - Configure try_files for client-side routing
  - Add health check endpoint
  - Enable gzip compression
  - _Requirements: 1.2, 2.4_

- [x] 4. Create Kong declarative configuration

  - Create `kong.yml` in project root with declarative config
  - Define backend-service with routes for /api and /graphql
  - Define frontend-service with route for /
  - Configure CORS plugin for backend service
  - Configure rate-limiting plugin for API protection
  - Enable WebSocket support for GraphQL subscriptions
  - _Requirements: 2.4, 4.4, 5.4_

- [x] 5. Create docker-compose.yml for orchestration

  - Create `docker-compose.yml` in project root
  - Define kong service with DB-less mode configuration
  - Define backend service with build context and health check
  - Define frontend service with build context
  - Configure Kong to depend on backend and frontend
  - Expose Kong ports 8000 (proxy) and 8001 (admin)
  - Mount kong.yml as volume for Kong
  - Set appropriate environment variables for all services
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 5.3_

- [x] 6. Create docker build script

  - Create `docker-build.sh` script in project root
  - Add logic to build backend image with version tag
  - Add logic to build frontend image with version tag
  - Tag both images with 'latest'
  - Support custom registry/repository names via environment variables
  - Add error handling and validation
  - Make script executable
  - _Requirements: 1.4, 3.1, 3.2_

- [x] 7. Create docker push script

  - Create `docker-push.sh` script in project root
  - Add Docker Hub authentication check
  - Push backend image with version and latest tags
  - Push frontend image with version and latest tags
  - Add error handling and validation
  - Display progress and success messages
  - Make script executable
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 8. Update Makefile with Docker targets

  - Add `docker-build` target to build images
  - Add `docker-run` target to start with docker-compose
  - Add `docker-stop` target to stop containers
  - Add `docker-push` target to push to Docker Hub
  - Add `docker-clean` target to remove containers and images
  - Add `kong-config` target to validate Kong configuration
  - Add `kong-logs` target to view Kong logs
  - _Requirements: 4.1, 4.2, 4.3_

- [ ] 9. Update README with Docker documentation

  - Add Docker prerequisites section (Docker, Docker Compose)
  - Add section for building images locally
  - Add section for running with docker-compose
  - Add section for pulling from Docker Hub
  - Document environment variables for configuration
  - Add troubleshooting section for common Docker issues
  - Document Kong gateway access (ports 8000, 8001)
  - Add production deployment best practices
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

- [x] 10. Create .dockerignore files

  - Create `backend/.dockerignore` to exclude build artifacts and IDE files
  - Create `frontend/.dockerignore` to exclude node_modules and build artifacts
  - Optimize build context size
  - _Requirements: 1.3, 5.2_

- [ ] 11. Update frontend to use environment-based API URL

  - Update `frontend/src/services/graphql.js` to use environment variable for WebSocket URL
  - Ensure API calls work through Kong gateway at /api path
  - Update GraphQL WebSocket connection to use Kong proxy
  - _Requirements: 2.4, 5.3_

- [ ] 12. Create Docker Hub repository documentation
  - Create `DOCKER_HUB.md` with quick start guide
  - Document available tags and versioning strategy
  - Provide example docker-compose.yml for users
  - Add configuration options and environment variables
  - Include links to full documentation
  - _Requirements: 4.1, 4.2, 4.3, 4.4_
