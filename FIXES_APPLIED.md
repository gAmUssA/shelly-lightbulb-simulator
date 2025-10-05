# Fixes Applied to Shelly Lightbulb Simulator

## Issues Identified

### 1. ❌ Frontend Colors Not Changing
**Symptom**: UI bulb color not updating when API requests are sent

**Root Cause**: GraphQL WebSocket subscription not working properly

### 2. ❌ Backend Error on Frontend Connection
**Error Message**: 
```
Unresolved IllegalStateException for executionId aff9cf79-e50e-436b-9bb7-b8d91d7f3ec7
java.lang.IllegalStateException: Expected Publisher for a subscription
```

**Root Cause**: GraphQL subscription was returning a Kotlin `Flow<LightState>` but Spring GraphQL WebSocket requires a reactive `Publisher<LightState>`

## Fixes Applied

### Fix 1: Convert Flow to Publisher in GraphQL Controller

**File**: `backend/src/main/kotlin/com/shelly/simulator/controller/GraphQLController.kt`

**Changes**:
1. Added import for `kotlinx.coroutines.reactive.asPublisher`
2. Added import for `org.reactivestreams.Publisher`
3. Changed subscription return type from `Flow<LightState>` to `Publisher<LightState>`
4. Used `.asPublisher()` extension to convert Flow to Publisher

**Before**:
```kotlin
@SubscriptionMapping
fun lightStateChanged(): Flow<LightState> {
    return lightService.getStateFlow()
}
```

**After**:
```kotlin
@SubscriptionMapping
fun lightStateChanged(): Publisher<LightState> {
    return lightService.getStateFlow().asPublisher()
}
```

### Fix 2: Added WebSocket Configuration

**File**: `backend/src/main/kotlin/com/shelly/simulator/config/WebSocketConfig.kt` (NEW)

**Purpose**: Enable WebSocket support in Spring Boot

```kotlin
@Configuration
@EnableWebSocket
class WebSocketConfig : WebSocketConfigurer {
    override fun registerWebSocketHandlers(registry: WebSocketHandlerRegistry) {
        // Spring GraphQL handles WebSocket registration automatically
    }
}
```

### Fix 3: Added CORS Configuration

**File**: `backend/src/main/kotlin/com/shelly/simulator/config/CorsConfig.kt` (NEW)

**Purpose**: Ensure CORS is properly configured for all endpoints including WebSocket

```kotlin
@Configuration
class CorsConfig : WebMvcConfigurer {
    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .maxAge(3600)
    }
}
```

## How It Works Now

### GraphQL WebSocket Subscription Flow

1. **Frontend connects** to `ws://localhost:8080/graphql/ws`
2. **Subscription established** with GraphQL query:
   ```graphql
   subscription {
     lightStateChanged {
       ison
       mode
       red
       green
       blue
       # ... other fields
     }
   }
   ```
3. **Backend emits** state changes through the reactive Publisher
4. **Frontend receives** updates via WebSocket callback
5. **UI updates** the bulb color in real-time

### State Update Flow

```
API Request → LightService.updateState() 
           → _stateFlow.emit(newState)
           → Publisher (via asPublisher())
           → WebSocket
           → Frontend GraphQL Client
           → React State Update
           → Bulb Component Re-render
           → Color Change Visible
```

## Required Action: Restart Backend

⚠️ **IMPORTANT**: The backend must be restarted for these changes to take effect.

### How to Restart:

1. **Stop the current backend** (Ctrl+C in the terminal running it)

2. **Start the backend** with one of these commands:
   ```bash
   # Option 1: Using Make
   make backend
   
   # Option 2: Using Gradle directly
   cd backend && ./gradlew bootRun
   ```

3. **Verify backend is running**:
   - Check console for: `Started ShellySimulatorApplication`
   - Backend should be on: `http://localhost:8080`
   - GraphQL WebSocket on: `ws://localhost:8080/graphql/ws`

4. **Frontend will automatically reconnect** when backend is ready

## Testing After Restart

### Test 1: Verify WebSocket Connection
1. Open browser console (F12)
2. Navigate to `http://localhost:3000`
3. Should NOT see: `WebSocket connection failed`
4. Should NOT see: `GraphQL subscription completed`

### Test 2: Test Real-Time Color Updates
1. Use API Tester to send: `GET /light/0?turn=on&red=255&green=0&blue=0`
2. Bulb should immediately turn RED
3. Send: `GET /light/0?turn=on&red=0&green=255&blue=0`
4. Bulb should immediately turn GREEN
5. Send: `GET /light/0?turn=off`
6. Bulb should immediately turn BLACK

### Test 3: Test RPC Updates
1. Select `/rpc` endpoint, method `POST`
2. Send: `{"id":1,"method":"RGBW.Set","params":{"id":0,"on":true,"rgb":[0,0,255]}}`
3. Bulb should immediately turn BLUE

## Technical Details

### Why This Fix Works

**Problem**: Spring GraphQL WebSocket subscriptions use Project Reactor (reactive streams) under the hood. Kotlin Flows are not directly compatible with reactive streams.

**Solution**: The `kotlinx-coroutines-reactor` library provides the `asPublisher()` extension function that bridges Kotlin Flows to reactive Publishers.

**Dependencies** (already in build.gradle.kts):
- `kotlinx-coroutines-core` - Kotlin coroutines and Flow
- `kotlinx-coroutines-reactor` - Bridge between coroutines and reactive streams
- `spring-boot-starter-graphql` - GraphQL support
- `spring-boot-starter-websocket` - WebSocket support

### Architecture

```
┌─────────────────┐
│   Frontend      │
│   (Preact)      │
└────────┬────────┘
         │ WebSocket
         │ (graphql-ws)
         ↓
┌─────────────────┐
│ Spring GraphQL  │
│   WebSocket     │
└────────┬────────┘
         │ Publisher
         ↓
┌─────────────────┐
│ GraphQL         │
│ Controller      │
└────────┬────────┘
         │ Flow.asPublisher()
         ↓
┌─────────────────┐
│ LightService    │
│ SharedFlow      │
└─────────────────┘
```

## Files Modified

1. ✅ `backend/src/main/kotlin/com/shelly/simulator/controller/GraphQLController.kt`
2. ✅ `backend/src/main/kotlin/com/shelly/simulator/config/WebSocketConfig.kt` (NEW)
3. ✅ `backend/src/main/kotlin/com/shelly/simulator/config/CorsConfig.kt` (NEW)

## Build Status

✅ Build successful
✅ No compilation errors
✅ All dependencies resolved

## Next Steps

1. ✅ Fixes applied
2. ✅ Code compiled
3. 🔄 **RESTART BACKEND** ← YOU ARE HERE
4. ⏳ Test WebSocket connection
5. ⏳ Test real-time color updates
6. ⏳ Verify all endpoints working

---

**Status**: Ready for backend restart and testing
