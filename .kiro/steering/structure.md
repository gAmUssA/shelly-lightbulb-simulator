# Project Structure

## Root Layout

```
.
├── backend/          # Spring Boot Kotlin backend
├── frontend/         # Preact frontend
└── docs/            # Project documentation
```

## Backend Structure

```
backend/
├── build.gradle.kts                    # Gradle build configuration
├── settings.gradle.kts                 # Gradle settings
├── gradlew, gradlew.bat               # Gradle wrapper scripts
└── src/main/
    ├── kotlin/com/shelly/simulator/
    │   ├── ShellySimulatorApplication.kt    # Main Spring Boot application
    │   ├── config/                          # Configuration classes
    │   ├── controller/
    │   │   ├── ShellyRestController.kt      # REST API endpoints (Gen1 & Gen2)
    │   │   └── GraphQLController.kt         # GraphQL resolvers
    │   ├── model/
    │   │   ├── LightState.kt               # Light state data class
    │   │   ├── DeviceStatus.kt             # Device status data class
    │   │   └── RpcModels.kt                # RPC request/response models
    │   └── service/
    │       └── LightService.kt             # Business logic & state management
    └── resources/
        ├── application.yml                 # Spring Boot configuration
        └── graphql/
            └── schema.graphqls             # GraphQL schema definition
```

## Frontend Structure

```
frontend/
├── package.json                # NPM dependencies
├── vite.config.js             # Vite configuration with proxy setup
├── index.html                 # HTML entry point
└── src/
    ├── main.jsx               # Application entry point
    ├── app.jsx                # Root component
    ├── app.css, index.css     # Global styles
    ├── components/
    │   ├── Bulb.jsx           # Visual bulb representation with color transitions
    │   └── ApiTester.jsx      # API endpoint testing UI
    └── services/
        └── graphql.js         # GraphQL WebSocket client
```

## Architecture Patterns

### Backend

- **Controller-Service pattern**: Controllers handle HTTP/GraphQL requests, services contain business logic
- **Immutable state copies**: Service returns copies of state to prevent external mutation
- **Coroutines**: Async operations use Kotlin coroutines with suspend functions
- **SharedFlow**: State changes broadcast via Kotlin Flow for GraphQL subscriptions
- **Data validation**: Input coercion ensures values stay within valid ranges

### Frontend

- **Component-based**: Preact functional components with hooks
- **Real-time updates**: GraphQL WebSocket subscriptions for live state changes
- **Proxy pattern**: Vite dev server proxies API calls to backend
- **Effect-driven**: useEffect hooks manage side effects and state synchronization

## Key Conventions

- Backend package structure follows domain organization (controller, service, model)
- Kotlin data classes for immutable models
- REST endpoints follow Shelly API conventions (/light/0, /color/0, /white/0, /rpc)
- GraphQL schema in separate .graphqls file
- Frontend components use JSX with Preact
- Color calculations (Kelvin to RGB) isolated in utility functions
