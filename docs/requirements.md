# Shelly Lightbulb REST API Simulator - Technical Specification

## 1. Project Overview

A web-based simulator that emulates the Shelly lightbulb REST API, allowing users to control a virtual light bulb through REST API calls. The webpage color changes to reflect the current bulb state and color.

### Tech Stack
- **Backend**: Spring Boot 3.x + Kotlin + GraphQL
- **Frontend**: Preact (lightweight React alternative)
- **API**: REST endpoints (mimicking Shelly API) + GraphQL subscription for real-time updates

---

## 2. Functional Requirements

### 2.1 Supported Shelly API Endpoints

#### Gen1 Style Endpoints

**GET/POST `/light/0`**
- Get current light state
- Control light state (on/off, brightness, color, etc.)

**GET/POST `/color/0`**
- Alias for `/light/0` in color mode
- Set RGB + white values

**GET/POST `/white/0`**
- Alias for `/light/0` in white mode
- Set brightness and color temperature

**GET `/status`**
- Get overall device status

**GET `/settings`**
- Get device settings

#### Gen2 Style RPC Endpoints

**POST `/rpc`**
- `RGBW.Set` - Set color, brightness, state
- `RGBW.Toggle` - Toggle on/off state
- `RGBW.GetStatus` - Get current status
- `RGBW.GetConfig` - Get configuration

### 2.2 Light Modes

1. **Color Mode**: Control via RGB + white channels
   - Red: 0-255
   - Green: 0-255
   - Blue: 0-255
   - White: 0-255
   - Gain: 0-100 (overall brightness multiplier)

2. **White Mode**: Control via brightness and temperature
   - Brightness: 0-100
   - Temperature: 3000-6500K

### 2.3 Effects (0-6)
- 0: Off (no effect)
- 1: Meteor Shower
- 2: Gradual Change
- 3: Flash
- 4-6: Custom effects (to be defined)

---

## 3. Backend Architecture (Spring Boot + Kotlin)

### 3.1 Project Structure
```
src/main/kotlin/com/shelly/simulator/
├── config/
│   ├── GraphQLConfig.kt
│   └── WebConfig.kt
├── controller/
│   ├── ShellyRestController.kt      # REST API endpoints
│   └── ShellyGraphQLController.kt   # GraphQL resolvers
├── model/
│   ├── LightState.kt
│   ├── DeviceStatus.kt
│   └── RpcRequest.kt
├── service/
│   ├── LightService.kt
│   └── EffectService.kt
└── ShellySimulatorApplication.kt
```

### 3.2 Data Models

#### LightState.kt
```kotlin
data class LightState(
    var ison: Boolean = false,
    var mode: LightMode = LightMode.COLOR,
    
    // Color mode properties
    var red: Int = 0,        // 0-255
    var green: Int = 0,      // 0-255
    var blue: Int = 0,       // 0-255
    var white: Int = 0,      // 0-255
    var gain: Int = 100,     // 0-100
    
    // White mode properties
    var brightness: Int = 100,  // 0-100
    var temp: Int = 4000,       // 3000-6500K
    
    // Common properties
    var transition: Int = 500,  // 0-5000ms
    var effect: Int = 0,        // 0-6
    var source: String = "http",
    
    // Timer properties
    var hasTimer: Boolean = false,
    var timerStarted: Long = 0,
    var timerDuration: Int = 0,
    var timerRemaining: Int = 0
)

enum class LightMode {
    COLOR, WHITE
}
```

#### DeviceStatus.kt
```kotlin
data class DeviceStatus(
    val deviceId: String = "shellysimulator-001",
    val deviceType: String = "SHRGBW2",
    val firmware: String = "1.0.0-simulator",
    val light: LightState = LightState(),
    val uptime: Long = System.currentTimeMillis() / 1000,
    val hasUpdate: Boolean = false
)
```

#### RpcRequest.kt
```kotlin
data class RpcRequest(
    val id: Int?,
    val method: String,
    val params: Map<String, Any>?
)

data class RpcResponse(
    val id: Int?,
    val result: Any?,
    val error: RpcError? = null
)

data class RpcError(
    val code: Int,
    val message: String
)
```

### 3.3 REST Controllers

#### ShellyRestController.kt
```kotlin
@RestController
@CrossOrigin(origins = ["*"])
class ShellyRestController(
    private val lightService: LightService
) {
    
    // Gen1 endpoints
    @GetMapping("/light/{id}")
    fun getLightState(@PathVariable id: Int): LightState {
        return lightService.getState()
    }
    
    @PostMapping("/light/{id}")
    fun setLightState(
        @PathVariable id: Int,
        @RequestParam params: Map<String, String>
    ): LightState {
        return lightService.updateState(params)
    }
    
    @GetMapping("/color/{id}")
    fun getColorState(@PathVariable id: Int): LightState {
        return lightService.getState()
    }
    
    @PostMapping("/color/{id}")
    fun setColorState(
        @PathVariable id: Int,
        @RequestParam params: Map<String, String>
    ): LightState {
        lightService.getState().mode = LightMode.COLOR
        return lightService.updateState(params)
    }
    
    @GetMapping("/white/{id}")
    fun getWhiteState(@PathVariable id: Int): LightState {
        return lightService.getState()
    }
    
    @PostMapping("/white/{id}")
    fun setWhiteState(
        @PathVariable id: Int,
        @RequestParam params: Map<String, String>
    ): LightState {
        lightService.getState().mode = LightMode.WHITE
        return lightService.updateState(params)
    }
    
    @GetMapping("/status")
    fun getStatus(): DeviceStatus {
        return lightService.getDeviceStatus()
    }
    
    // Gen2 RPC endpoint
    @PostMapping("/rpc")
    fun handleRpc(@RequestBody request: RpcRequest): RpcResponse {
        return when (request.method) {
            "RGBW.Set" -> {
                val result = lightService.updateStateFromRpc(request.params ?: emptyMap())
                RpcResponse(request.id, result)
            }
            "RGBW.Toggle" -> {
                val result = lightService.toggle()
                RpcResponse(request.id, result)
            }
            "RGBW.GetStatus" -> {
                RpcResponse(request.id, lightService.getState())
            }
            "RGBW.GetConfig" -> {
                RpcResponse(request.id, lightService.getConfig())
            }
            else -> {
                RpcResponse(
                    request.id,
                    null,
                    RpcError(-32601, "Method not found: ${request.method}")
                )
            }
        }
    }
}
```

### 3.4 GraphQL Schema

#### schema.graphqls
```graphql
type Query {
    lightState: LightState!
    deviceStatus: DeviceStatus!
}

type Mutation {
    setLight(input: LightInput!): LightState!
    toggleLight: LightState!
    setEffect(effect: Int!): LightState!
}

type Subscription {
    lightStateChanged: LightState!
}

type LightState {
    ison: Boolean!
    mode: String!
    red: Int!
    green: Int!
    blue: Int!
    white: Int!
    gain: Int!
    brightness: Int!
    temp: Int!
    transition: Int!
    effect: Int!
    source: String!
}

type DeviceStatus {
    deviceId: String!
    deviceType: String!
    firmware: String!
    light: LightState!
    uptime: Int!
}

input LightInput {
    turn: String
    mode: String
    red: Int
    green: Int
    blue: Int
    white: Int
    gain: Int
    brightness: Int
    temp: Int
    transition: Int
    effect: Int
}
```

### 3.5 Service Layer

#### LightService.kt
```kotlin
@Service
class LightService {
    private var state = LightState()
    private val stateFlow = MutableSharedFlow<LightState>(replay = 1)
    
    init {
        // Initialize with default state
        GlobalScope.launch {
            stateFlow.emit(state)
        }
    }
    
    fun getState(): LightState = state
    
    fun getDeviceStatus(): DeviceStatus {
        return DeviceStatus(light = state)
    }
    
    fun updateState(params: Map<String, String>): LightState {
        params["turn"]?.let { 
            state.ison = when(it) {
                "on" -> true
                "off" -> false
                "toggle" -> !state.ison
                else -> state.ison
            }
        }
        
        params["mode"]?.let { state.mode = LightMode.valueOf(it.uppercase()) }
        params["red"]?.toIntOrNull()?.let { state.red = it.coerceIn(0, 255) }
        params["green"]?.toIntOrNull()?.let { state.green = it.coerceIn(0, 255) }
        params["blue"]?.toIntOrNull()?.let { state.blue = it.coerceIn(0, 255) }
        params["white"]?.toIntOrNull()?.let { state.white = it.coerceIn(0, 255) }
        params["gain"]?.toIntOrNull()?.let { state.gain = it.coerceIn(0, 100) }
        params["brightness"]?.toIntOrNull()?.let { state.brightness = it.coerceIn(0, 100) }
        params["temp"]?.toIntOrNull()?.let { state.temp = it.coerceIn(3000, 6500) }
        params["transition"]?.toIntOrNull()?.let { state.transition = it.coerceIn(0, 5000) }
        params["effect"]?.toIntOrNull()?.let { state.effect = it.coerceIn(0, 6) }
        
        state.source = "http"
        
        // Emit state change for GraphQL subscription
        GlobalScope.launch {
            stateFlow.emit(state.copy())
        }
        
        return state
    }
    
    fun updateStateFromRpc(params: Map<String, Any>): LightState {
        val stringParams = params.mapValues { it.value.toString() }
        
        // Handle RGB array
        (params["rgb"] as? List<*>)?.let { rgb ->
            if (rgb.size >= 3) {
                state.red = (rgb[0] as? Number)?.toInt()?.coerceIn(0, 255) ?: 0
                state.green = (rgb[1] as? Number)?.toInt()?.coerceIn(0, 255) ?: 0
                state.blue = (rgb[2] as? Number)?.toInt()?.coerceIn(0, 255) ?: 0
            }
        }
        
        (params["on"] as? Boolean)?.let { state.ison = it }
        (params["brightness"] as? Number)?.toInt()?.let { state.brightness = it.coerceIn(0, 100) }
        (params["white"] as? Number)?.toInt()?.let { state.white = it.coerceIn(0, 255) }
        
        state.source = "rpc"
        
        GlobalScope.launch {
            stateFlow.emit(state.copy())
        }
        
        return state
    }
    
    fun toggle(): LightState {
        state.ison = !state.ison
        state.source = "rpc"
        
        GlobalScope.launch {
            stateFlow.emit(state.copy())
        }
        
        return state
    }
    
    fun getConfig(): Map<String, Any> {
        return mapOf(
            "id" to 0,
            "name" to "Shelly Simulator RGBW",
            "initial_state" to mapOf("brightness" to 100)
        )
    }
    
    fun getStateFlow() = stateFlow.asSharedFlow()
}
```

---

## 4. Frontend (Preact)

### 4.1 Project Structure
```
src/
├── components/
│   ├── Bulb.jsx           # Visual bulb representation
│   ├── Controls.jsx       # Manual controls
│   ├── ApiTester.jsx      # API endpoint tester
│   └── StatusDisplay.jsx  # Current state display
├── services/
│   ├── api.js            # REST API client
│   └── graphql.js        # GraphQL/WebSocket client
├── App.jsx
└── main.jsx
```

### 4.2 Key Components

#### Bulb.jsx
```jsx
import { h } from 'preact';
import { useEffect, useState } from 'preact/hooks';

export default function Bulb({ state }) {
    const [bgColor, setBgColor] = useState('#000000');
    const [transition, setTransition] = useState(500);
    
    useEffect(() => {
        if (!state.ison) {
            setBgColor('#000000');
            return;
        }
        
        if (state.mode === 'color') {
            const { red, green, blue, gain } = state;
            const factor = gain / 100;
            const r = Math.round(red * factor);
            const g = Math.round(green * factor);
            const b = Math.round(blue * factor);
            setBgColor(`rgb(${r}, ${g}, ${b})`);
        } else {
            // White mode - convert temperature to RGB
            const rgb = kelvinToRgb(state.temp);
            const factor = state.brightness / 100;
            const r = Math.round(rgb.r * factor);
            const g = Math.round(rgb.g * factor);
            const b = Math.round(rgb.b * factor);
            setBgColor(`rgb(${r}, ${g}, ${b})`);
        }
        
        setTransition(state.transition);
    }, [state]);
    
    return (
        <div 
            style={{
                width: '100vw',
                height: '100vh',
                backgroundColor: bgColor,
                transition: `background-color ${transition}ms ease-in-out`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center'
            }}
        >
            <div style={{
                width: '200px',
                height: '200px',
                borderRadius: '50%',
                backgroundColor: bgColor,
                boxShadow: `0 0 100px 50px ${bgColor}`,
                border: '5px solid rgba(255,255,255,0.3)'
            }} />
        </div>
    );
}

function kelvinToRgb(kelvin) {
    const temp = kelvin / 100;
    let r, g, b;
    
    if (temp <= 66) {
        r = 255;
        g = Math.max(0, Math.min(255, 99.4708025861 * Math.log(temp) - 161.1195681661));
    } else {
        r = Math.max(0, Math.min(255, 329.698727446 * Math.pow(temp - 60, -0.1332047592)));
        g = Math.max(0, Math.min(255, 288.1221695283 * Math.pow(temp - 60, -0.0755148492)));
    }
    
    if (temp >= 66) {
        b = 255;
    } else if (temp <= 19) {
        b = 0;
    } else {
        b = Math.max(0, Math.min(255, 138.5177312231 * Math.log(temp - 10) - 305.0447927307));
    }
    
    return { r: Math.round(r), g: Math.round(g), b: Math.round(b) };
}
```

#### ApiTester.jsx
```jsx
import { h } from 'preact';
import { useState } from 'preact/hooks';

export default function ApiTester() {
    const [endpoint, setEndpoint] = useState('/light/0');
    const [method, setMethod] = useState('POST');
    const [params, setParams] = useState('turn=on&red=255&green=0&blue=0');
    const [response, setResponse] = useState('');
    
    const sendRequest = async () => {
        try {
            const url = `http://localhost:8080${endpoint}?${params}`;
            const res = await fetch(url, { method });
            const data = await res.json();
            setResponse(JSON.stringify(data, null, 2));
        } catch (error) {
            setResponse(`Error: ${error.message}`);
        }
    };
    
    return (
        <div style={{ padding: '20px', backgroundColor: 'rgba(255,255,255,0.9)', borderRadius: '8px' }}>
            <h3>API Tester</h3>
            <select value={endpoint} onChange={e => setEndpoint(e.target.value)}>
                <option value="/light/0">/light/0</option>
                <option value="/color/0">/color/0</option>
                <option value="/white/0">/white/0</option>
                <option value="/status">/status</option>
                <option value="/rpc">/rpc</option>
            </select>
            <select value={method} onChange={e => setMethod(e.target.value)}>
                <option>GET</option>
                <option>POST</option>
            </select>
            <input 
                type="text" 
                value={params} 
                onChange={e => setParams(e.target.value)}
                style={{ width: '400px', marginLeft: '10px' }}
                placeholder="turn=on&red=255"
            />
            <button onClick={sendRequest}>Send</button>
            <pre style={{ marginTop: '10px', maxHeight: '200px', overflow: 'auto' }}>
                {response}
            </pre>
        </div>
    );
}
```

### 4.3 GraphQL WebSocket Subscription

```javascript
// graphql.js
import { createClient } from 'graphql-ws';

const client = createClient({
    url: 'ws://localhost:8080/graphql/ws',
});

export function subscribeLightState(callback) {
    return client.subscribe(
        {
            query: `
                subscription {
                    lightStateChanged {
                        ison
                        mode
                        red
                        green
                        blue
                        white
                        gain
                        brightness
                        temp
                        transition
                        effect
                    }
                }
            `,
        },
        {
            next: (data) => callback(data.data.lightStateChanged),
            error: (error) => console.error('Subscription error:', error),
            complete: () => console.log('Subscription complete'),
        }
    );
}
```

---

## 5. Implementation Steps

### Phase 1: Backend Setup
1. Initialize Spring Boot project with Kotlin
2. Add dependencies: Spring Web, GraphQL, WebSocket
3. Implement data models
4. Create REST controllers for Shelly endpoints
5. Implement LightService with state management
6. Set up GraphQL schema and resolvers
7. Implement WebSocket subscription

### Phase 2: Frontend Setup
1. Initialize Preact project
2. Create Bulb component with color transitions
3. Implement API tester component
4. Set up GraphQL WebSocket client
5. Connect components to backend

### Phase 3: Testing & Refinement
1. Test all REST endpoints
2. Test GraphQL queries/mutations/subscriptions
3. Verify color transitions and effects
4. Add error handling
5. Performance optimization

---

## 6. API Examples

### REST API Examples

**Turn on with red color:**
```bash
curl -X POST "http://localhost:8080/light/0?turn=on&red=255&green=0&blue=0&gain=100"
```

**Set white mode with warm temperature:**
```bash
curl -X POST "http://localhost:8080/white/0?turn=on&brightness=80&temp=3000"
```

**Toggle light:**
```bash
curl -X POST "http://localhost:8080/light/0?turn=toggle"
```

**RPC Set (Gen2):**
```bash
curl -X POST "http://localhost:8080/rpc" \
  -H "Content-Type: application/json" \
  -d '{"id":1,"method":"RGBW.Set","params":{"id":0,"on":true,"rgb":[255,128,0],"brightness":80}}'
```

### GraphQL Examples

**Query:**
```graphql
query {
    lightState {
        ison
        red
        green
        blue
        brightness
    }
}
```

**Mutation:**
```graphql
mutation {
    setLight(input: {
        turn: "on"
        red: 255
        green: 0
        blue: 0
        gain: 100
    }) {
        ison
        red
        green
        blue
    }
}
```

---

## 7. Configuration Files

### application.yml
```yaml
server:
  port: 8080

spring:
  graphql:
    websocket:
      path: /graphql/ws
    path: /graphql
    
cors:
  allowed-origins: "*"
  allowed-methods: "*"
```

### package.json (Frontend)
```json
{
  "dependencies": {
    "preact": "^10.19.0",
    "graphql-ws": "^5.14.0"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "@preact/preset-vite": "^2.7.0"
  }
}
```

### build.gradle.kts
```kotlin
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-graphql")
    implementation("org.springframework.boot:spring-boot-starter-websocket")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
}
```

---

## 8. Future Enhancements

1. **Persistent State**: Save state to database
2. **Multiple Devices**: Simulate multiple bulbs
3. **Advanced Effects**: Implement all 6 effects with animations
4. **Timers**: Full timer support with auto flip-back
5. **Scenes**: Predefined color scenes
6. **Authentication**: API key support
7. **MQTT Support**: Add MQTT protocol simulation
8. **Mobile App**: Native mobile control app