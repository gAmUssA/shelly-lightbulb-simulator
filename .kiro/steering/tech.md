# Technology Stack

## Backend

- **Language**: Kotlin 1.9.20
- **Framework**: Spring Boot 3.2.0
- **Java Version**: 21
- **Build Tool**: Gradle (Kotlin DSL)
- **Key Dependencies**:
  - spring-boot-starter-web (REST API)
  - spring-boot-starter-graphql (GraphQL)
  - spring-boot-starter-websocket (WebSocket subscriptions)
  - kotlinx-coroutines-core (async operations)
  - jackson-module-kotlin (JSON serialization)

## Frontend

- **Framework**: Preact 10.27.2 (lightweight React alternative)
- **Build Tool**: Vite (using rolldown-vite 7.1.14)
- **Key Dependencies**:
  - graphql-ws 6.0.6 (WebSocket subscriptions)
  - @preact/preset-vite (Vite integration)

## Common Commands

### Backend

```bash
# Build the project
./gradlew build

# Run the application
./gradlew bootRun

# Run tests
./gradlew test

# Clean build artifacts
./gradlew clean
```

Backend runs on port 8080 by default.

### Frontend

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

Frontend runs on port 3000 by default with proxy to backend on 8080.

## API Protocols

- REST API (Shelly Gen1 and Gen2 RPC endpoints)
- GraphQL (queries, mutations, subscriptions)
- WebSocket (for real-time state updates)

## Configuration

- Backend: `backend/src/main/resources/application.yml`
- Frontend: `frontend/vite.config.js`
- CORS enabled for all origins in development
