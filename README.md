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

- Java 21 or higher
- Node.js 18+ and npm
- Make (optional, for using Makefile commands)

## Quick Start

### Using Make (Recommended)

```bash
# Install all dependencies
make install

# Run both frontend and backend
make dev

# Or run them separately in different terminals:
make backend
make frontend
```

### Manual Setup

#### Backend

```bash
cd backend
./gradlew build
./gradlew bootRun
```

Backend runs on http://localhost:8080

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend runs on http://localhost:3000

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

### Backend won't start
- Ensure Java 21 is installed: `java -version`
- Check if port 8080 is available
- Run `./gradlew clean build` to rebuild

### Frontend won't start
- Ensure Node.js 18+ is installed: `node -v`
- Check if port 3000 is available
- Delete `node_modules` and run `npm install` again

### WebSocket connection fails
- Ensure backend is running on port 8080
- Check browser console for connection errors
- Verify CORS settings in `application.yml`

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
