# Shelly Lightbulb REST API Simulator

A web-based simulator that emulates the Shelly smart lightbulb REST API. Control a virtual light bulb through REST API calls and see real-time visual feedback as the webpage color changes to reflect the current bulb state.

## Features

- 🔌 Simulates both Shelly Gen1 and Gen2 API endpoints
- 🎨 Real-time visual feedback with smooth color transitions
- 🌈 Supports color mode (RGB + white channels) and white mode (brightness + temperature)
- ⚡ GraphQL subscriptions for live state updates
- 🧪 Built-in API tester for manual testing
- ✨ Effects support (0-6)

## Technology Stack

### Backend

- **Language**: Kotlin 1.9.20
- **Framework**: Spring Boot 3.2.0
- **Java Version**: 21
- **Build Tool**: Gradle (Kotlin DSL)

### Frontend

- **Framework**: Preact 10.27.2
- **Build Tool**: Vite (rolldown-vite 7.1.14)
- **Real-time**: GraphQL WebSocket subscriptions

## Prerequisites

### Local Development

- Java 21 or higher
- Node.js 18+ and npm
- Make (optional, for using Makefile commands)

### Docker Deployment

- Docker 20.10+ or higher
- Docker Compose 2.0+ or higher

## Quick Start

### Option 1: Docker (Recommended for Quick Setup)

Pull and run the pre-built images from Docker Hub:

```bash
# Pull images
docker pull vikgamov/shelly-simulator-backend:latest
docker pull vikgamov/shelly-simulator-frontend:latest

# Run with docker-compose
docker-compose up
```

Access the application:

- Frontend: <http://localhost:8000>
- Backend API: <http://localhost:8000/api>
- GraphQL: <http://localhost:8000/graphql>
- Kong Admin API: <http://localhost:8001>

### Option 2: Using Make (Local Development)

```bash
# Install all dependencies
make install

# Run both frontend and backend
make dev

# Or run them separately in different terminals:
make backend
make frontend
```

### Option 3: Manual Setup (Local Development)

#### Backend

```bash
cd backend
./gradlew build
./gradlew bootRun
```

Backend runs on <http://localhost:8080>

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend runs on <http://localhost:3000>

## API Endpoints

### REST API (Gen1)

- `GET /light/0` - Get light state
- `GET /light/0?turn=on` - Turn light on
- `GET /light/0?turn=off` - Turn light off
- `GET /color/0?red=255&green=0&blue=0&gain=100` - Set color mode
- `GET /white/0?brightness=80&temp=4500` - Set white mode
- `GET /status` - Get device status

### REST API (Gen2 RPC)

```bash
POST /rpc
Content-Type: application/json

{
  "id": 1,
  "method": "Light.Set",
  "params": {
    "id": 0,
    "on": true,
    "rgb": [255, 0, 0]
  }
}
```

### GraphQL

GraphQL endpoint: http://localhost:8080/graphql

**Query:**

```graphql
query {
  lightState {
    ison
    mode
    red
    green
    blue
    brightness
    temp
  }
}
```

**Mutation:**

```graphql
mutation {
  setLight(on: true, red: 255, green: 0, blue: 0) {
    ison
    red
    green
    blue
  }
}
```

**Subscription:**

```graphql
subscription {
  lightStateChanged {
    ison
    mode
    red
    green
    blue
    brightness
    temp
  }
}
```

## Testing

### Backend Tests

```bash
# Run all backend tests
make test-backend

# Or manually
cd backend
./gradlew test
```

### Frontend Tests

```bash
# Run all frontend tests
make test-frontend

# Or manually
cd frontend
npm test
```

### Manual Testing

1. Start both backend and frontend
2. Open http://localhost:3000 in your browser
3. Use the built-in API Tester panel (top-right corner) to send requests
4. Watch the bulb color change in real-time

### Example Test Scenarios

**Turn on red light:**

```bash
curl "http://localhost:8080/light/0?turn=on&red=255&green=0&blue=0"
```

**Set warm white:**

```bash
curl "http://localhost:8080/white/0?turn=on&brightness=100&temp=3000"
```

**Use RPC to set purple:**

```bash
curl -X POST http://localhost:8080/rpc \
  -H "Content-Type: application/json" \
  -d '{"id":1,"method":"Light.Set","params":{"id":0,"on":true,"rgb":[128,0,128]}}'
```

## Project Structure

```
.
├── backend/              # Spring Boot Kotlin backend
│   ├── src/
│   │   └── main/
│   │       ├── kotlin/
│   │       │   └── com/shelly/simulator/
│   │       │       ├── controller/    # REST & GraphQL controllers
│   │       │       ├── model/         # Data models
│   │       │       └── service/       # Business logic
│   │       └── resources/
│   │           ├── application.yml
│   │           └── graphql/schema.graphqls
│   └── build.gradle.kts
│
├── frontend/             # Preact frontend
│   ├── src/
│   │   ├── components/
│   │   │   ├── Bulb.jsx          # Visual bulb component
│   │   │   └── ApiTester.jsx     # API testing UI
│   │   ├── services/
│   │   │   └── graphql.js        # GraphQL WebSocket client
│   │   └── app.jsx               # Main app component
│   ├── package.json
│   └── vite.config.js
│
└── docs/                 # Documentation
```

## Device Simulation

Simulates a Shelly RGBW2 device with:

- Device ID: `shellysimulator-001`
- Firmware: `1.0.0-simulator`
- Color temperature range: 3000-6500K
- RGB values: 0-255
- Brightness/Gain: 0-100
- Transition times: 0-5000ms
- Effects: 0-6

## Docker Deployment

### Building Images Locally

Build Docker images from source:

```bash
# Build both images using Make
make docker-build

# Or build manually
docker build -t shelly-simulator-backend:latest ./backend
docker build -t shelly-simulator-frontend:latest ./frontend
```

The build script creates optimized multi-stage builds:

- Backend: ~400MB (Gradle build + JRE runtime)
- Frontend: ~30MB (Node build + nginx runtime)

### Running with Docker Compose

Start the complete application stack with Kong API Gateway:

```bash
# Start all services
make docker-run
# or
docker-compose up

# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
make docker-stop
# or
docker-compose down
```

The docker-compose stack includes:

- Kong API Gateway (ports 8000, 8001)
- Backend service (internal)
- Frontend service (internal)

All traffic routes through Kong at port 8000.

### Pulling from Docker Hub

Pre-built images are available on Docker Hub:

```bash
# Pull latest images
docker pull vikgamov/shelly-simulator-backend:latest
docker pull vikgamov/shelly-simulator-frontend:latest

# Pull specific version
docker pull vikgamov/shelly-simulator-backend:1.0.0
docker pull vikgamov/shelly-simulator-frontend:1.0.0
```

### Pushing to Docker Hub

Push your custom builds to Docker Hub:

```bash
# Login to Docker Hub
docker login

# Push images using Make
make docker-push

# Or push manually
docker push vikgamov/shelly-simulator-backend:latest
docker push vikgamov/shelly-simulator-frontend:latest
```

### Environment Variables

Configure the application using environment variables in `docker-compose.yml`:

#### Backend Environment Variables

```yaml
environment:
  - SPRING_PROFILES_ACTIVE=docker
  - SERVER_PORT=8080
  - CORS_ALLOWED_ORIGINS=*
```

#### Frontend Environment Variables

```yaml
environment:
  - VITE_API_BASE_URL=/api
  - VITE_GRAPHQL_WS_URL=ws://localhost:8000/graphql
```

#### Kong Environment Variables

```yaml
environment:
  - KONG_DATABASE=off
  - KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml
  - KONG_PROXY_ACCESS_LOG=/dev/stdout
  - KONG_ADMIN_ACCESS_LOG=/dev/stdout
```

### Kong API Gateway

Kong acts as the API gateway routing all traffic:

**Proxy Port (8000):**

- `/` → Frontend (nginx)
- `/api/*` → Backend REST API
- `/graphql` → Backend GraphQL

**Admin API Port (8001):**

- Access Kong's admin API for configuration
- View routes: `curl http://localhost:8001/routes`
- View services: `curl http://localhost:8001/services`

**Features:**

- CORS handling for cross-origin requests
- Rate limiting (100 requests/minute)
- Request/response logging
- WebSocket support for GraphQL subscriptions
- Health checks for upstream services

**Validate Kong Configuration:**

```bash
# Check Kong configuration
make kong-config

# View Kong logs
make kong-logs
```

### Docker Commands Reference

```bash
# Build images
make docker-build

# Run with docker-compose
make docker-run

# Stop containers
make docker-stop

# Push to Docker Hub
make docker-push

# Clean up containers and images
make docker-clean

# View Kong configuration
make kong-config

# View Kong logs
make kong-logs
```

### Production Deployment Best Practices

#### Security

1. **Use specific version tags** instead of `latest` in production:

   ```yaml
   image: vikgamov/shelly-simulator-backend:1.0.0
   ```

2. **Restrict CORS origins** in production:

   ```yaml
   environment:
     - CORS_ALLOWED_ORIGINS=https://yourdomain.com
   ```

3. **Secure Kong Admin API**:

   - Don't expose port 8001 publicly
   - Use Kong's RBAC for access control
   - Enable authentication plugins

4. **Use Docker secrets** for sensitive data:

   ```yaml
   secrets:
     - db_password
   ```

5. **Run containers as non-root users** (already configured in Dockerfiles)

#### Performance

1. **Set resource limits**:

   ```yaml
   deploy:
     resources:
       limits:
         cpus: "1"
         memory: 512M
       reservations:
         cpus: "0.5"
         memory: 256M
   ```

2. **Enable health checks**:

   ```yaml
   healthcheck:
     test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
     interval: 30s
     timeout: 10s
     retries: 3
   ```

3. **Use Docker BuildKit** for faster builds:
   ```bash
   DOCKER_BUILDKIT=1 docker build -t myimage .
   ```

#### Monitoring

1. **Collect logs** from all containers:

   ```bash
   docker-compose logs -f --tail=100
   ```

2. **Monitor Kong metrics**:

   - Enable Prometheus plugin
   - Use Kong's built-in logging

3. **Set up health check endpoints**:
   - Backend: `/actuator/health`
   - Frontend: `/health`
   - Kong: `/status`

#### Scaling

1. **Scale services** with docker-compose:

   ```bash
   docker-compose up --scale backend=3
   ```

2. **Use orchestration platforms** for production:

   - Kubernetes
   - Docker Swarm
   - AWS ECS/Fargate

3. **Configure Kong load balancing** for multiple backend instances

### Docker Troubleshooting

#### Images won't build

**Gradle build fails:**

```bash
# Clean gradle cache
cd backend
./gradlew clean

# Rebuild with verbose output
docker build --no-cache -t shelly-simulator-backend:latest ./backend
```

**NPM build fails:**

```bash
# Clear npm cache
cd frontend
npm cache clean --force

# Rebuild with verbose output
docker build --no-cache -t shelly-simulator-frontend:latest ./frontend
```

#### Containers won't start

**Check container logs:**

```bash
docker-compose logs backend
docker-compose logs frontend
docker-compose logs kong
```

**Verify port availability:**

```bash
# Check if ports 8000, 8001 are available
lsof -i :8000
lsof -i :8001
```

**Restart services:**

```bash
docker-compose restart
```

#### Kong gateway issues

**Kong won't start:**

```bash
# Validate Kong configuration
docker run --rm -v $(pwd)/kong.yml:/kong.yml kong:latest kong config parse /kong.yml

# Check Kong logs
docker-compose logs kong
```

**Routes not working:**

```bash
# List all routes
curl http://localhost:8001/routes

# Test backend connectivity from Kong container
docker-compose exec kong curl http://backend:8080/status
```

#### Network connectivity issues

**Frontend can't reach backend:**

```bash
# Check if services are on same network
docker network inspect docker-containerization_default

# Test connectivity between containers
docker-compose exec frontend ping backend
```

**WebSocket connection fails:**

- Ensure Kong WebSocket support is enabled
- Check browser console for connection errors
- Verify GraphQL subscription endpoint: `ws://localhost:8000/graphql`

#### Image size too large

**Optimize backend image:**

- Ensure multi-stage build is used
- Check .dockerignore excludes build artifacts
- Use alpine-based images

**Optimize frontend image:**

- Verify production build is used
- Check node_modules aren't copied to final image
- Enable nginx gzip compression

#### Permission issues

**Container runs as root:**

```bash
# Verify non-root user in Dockerfile
docker-compose exec backend whoami
# Should output: appuser
```

**Volume mount permissions:**

```bash
# Fix permissions on mounted volumes
chmod -R 755 ./kong.yml
```

#### Clean up and reset

**Remove all containers and images:**

```bash
make docker-clean

# Or manually
docker-compose down -v
docker rmi shelly-simulator-backend:latest
docker rmi shelly-simulator-frontend:latest
```

**Prune unused Docker resources:**

```bash
docker system prune -a
```

## Development

### Build

```bash
# Build backend
make build-backend

# Build frontend
make build-frontend

# Build both
make build
```

### Clean

```bash
# Clean all build artifacts
make clean
```

## Troubleshooting

### Local Development Issues

#### Backend won't start

- Ensure Java 21 is installed: `java -version`
- Check if port 8080 is available
- Run `./gradlew clean build` to rebuild

#### Frontend won't start

- Ensure Node.js 18+ is installed: `node -v`
- Check if port 3000 is available
- Delete `node_modules` and run `npm install` again

#### WebSocket connection fails

- Ensure backend is running on port 8080
- Check browser console for connection errors
- Verify CORS settings in `application.yml`

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
