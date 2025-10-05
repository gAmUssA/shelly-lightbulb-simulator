# Implementation Plan

- [x] 1. Initialize backend project structure

  - Create Spring Boot project with Kotlin using Gradle
  - Add dependencies: spring-boot-starter-web, spring-boot-starter-graphql, spring-boot-starter-websocket, kotlin-reflect, jackson-module-kotlin, kotlinx-coroutines-core, kotlinx-coroutines-reactor
  - Create package structure: config/, controller/, model/, service/
  - Configure application.yml with server port 8080, GraphQL paths, and CORS settings
  - _Requirements: 14.1_

- [x] 2. Implement core data models

  - [x] 2.1 Create LightState data class with all properties (ison, mode, red, green, blue, white, gain, brightness, temp, transition, effect, source)

    - Define LightMode enum with COLOR and WHITE values
    - Set default values matching requirements
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 5.1, 5.2, 6.1, 12.1_

  - [x] 2.2 Create DeviceStatus data class

    - Include deviceId, deviceType, firmware, light, uptime, hasUpdate properties
    - Set default device metadata values
    - _Requirements: 1.7_

  - [x] 2.3 Create RPC request/response models
    - Create RpcRequest data class with id, method, params
    - Create RpcResponse data class with id, result, error
    - Create RpcError data class with code and message
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [x] 3. Implement LightService with state management

  - [x] 3.1 Create LightService class with in-memory state

    - Initialize mutable LightState instance with defaults
    - Create MutableSharedFlow<LightState> with replay=1 for broadcasting
    - Implement getState() method
    - Implement getDeviceStatus() method with uptime calculation
    - _Requirements: 14.1, 14.2, 14.3_

  - [x] 3.2 Implement REST parameter update logic

    - Create updateState(params: Map<String, String>) method
    - Parse and apply turn parameter (on/off/toggle)
    - Parse and apply mode parameter
    - Parse and apply color parameters (red, green, blue, white, gain) with coercion to 0-255 or 0-100
    - Parse and apply white parameters (brightness, temp) with coercion to valid ranges
    - Parse and apply transition parameter with coercion to 0-5000
    - Parse and apply effect parameter with coercion to 0-6
    - Set source to "http"
    - Emit updated state to SharedFlow using coroutine
    - _Requirements: 1.2, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.1, 4.2, 4.3, 5.1, 5.2, 5.3, 6.1, 6.2, 12.1, 12.2, 15.1, 15.2, 15.3, 15.5_

  - [x] 3.3 Implement RPC parameter update logic

    - Create updateStateFromRpc(params: Map<String, Any>) method
    - Handle rgb array parameter by extracting red, green, blue values
    - Handle on boolean parameter mapping to ison
    - Handle brightness and white numeric parameters
    - Set source to "rpc"
    - Emit updated state to SharedFlow
    - _Requirements: 2.1, 15.4_

  - [x] 3.4 Implement toggle and config methods
    - Create toggle() method that inverts ison value
    - Set source to "rpc" on toggle
    - Emit state change
    - Create getConfig() method returning device configuration map
    - Create getStateFlow() method returning SharedFlow as read-only
    - _Requirements: 2.2, 2.4, 5.3_

- [x] 4. Implement REST API controller

  - [x] 4.1 Create ShellyRestController with Gen1 endpoints

    - Add @RestController and @CrossOrigin annotations
    - Inject LightService dependency
    - Implement GET /light/{id} returning current state
    - Implement POST /light/{id} with @RequestParam, call updateState()
    - Implement GET /color/{id} returning current state
    - Implement POST /color/{id} setting mode to COLOR then calling updateState()
    - Implement GET /white/{id} returning current state
    - Implement POST /white/{id} setting mode to WHITE then calling updateState()
    - Implement GET /status returning device status
    - Implement GET /settings returning configuration
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 13.1, 13.2, 13.3_

  - [x] 4.2 Implement RPC endpoint
    - Add POST /rpc endpoint with @RequestBody RpcRequest
    - Implement method routing for RGBW.Set, RGBW.Toggle, RGBW.GetStatus, RGBW.GetConfig
    - Call appropriate service methods based on method name
    - Return RpcResponse with matching id
    - Return error response for unknown methods with code -32601
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [x] 5. Implement GraphQL schema and resolvers

  - [x] 5.1 Create GraphQL schema file

    - Define Query type with lightState and deviceStatus
    - Define Mutation type with setLight, toggleLight, setEffect
    - Define Subscription type with lightStateChanged
    - Define LightState type with all properties
    - Define DeviceStatus type
    - Define LightInput input type with optional fields
    - Place schema.graphqls in src/main/resources/graphql/
    - _Requirements: 8.1, 8.2, 9.1, 9.2, 9.3, 10.1_

  - [x] 5.2 Create GraphQL controller with resolvers
    - Create @Controller class for GraphQL
    - Inject LightService
    - Implement @QueryMapping for lightState returning service.getState()
    - Implement @QueryMapping for deviceStatus returning service.getDeviceStatus()
    - Implement @MutationMapping for setLight accepting LightInput, converting to map, calling service
    - Implement @MutationMapping for toggleLight calling service.toggle()
    - Implement @MutationMapping for setEffect calling service with effect parameter
    - Implement @SubscriptionMapping for lightStateChanged returning service.getStateFlow()
    - _Requirements: 8.1, 8.2, 8.3, 9.1, 9.2, 9.3, 10.1, 10.2, 10.3_

- [x] 6. Initialize frontend project structure

  - Create Preact project using Vite
  - Install dependencies: preact, graphql-ws
  - Install dev dependencies: vite, @preact/preset-vite
  - Configure vite.config.js with Preact plugin and proxy to backend
  - Create src/ directory with components/ and services/ subdirectories
  - _Requirements: 7.6_

- [x] 7. Implement GraphQL WebSocket client service

  - Create src/services/graphql.js
  - Import createClient from graphql-ws
  - Create client instance connecting to ws://localhost:8080/graphql/ws
  - Export subscribeLightState(callback) function
  - Implement subscription query for lightStateChanged with all fields
  - Handle next, error, and complete callbacks
  - _Requirements: 10.1, 10.2, 10.4_

- [x] 8. Implement Bulb component

  - [x] 8.1 Create Bulb component with color rendering

    - Create src/components/Bulb.jsx
    - Accept state prop
    - Use useState for bgColor and transition
    - Use useEffect to update colors when state changes
    - Render full-screen div with dynamic background color
    - Render centered circular bulb element with glow effect using box-shadow
    - Apply CSS transition with dynamic duration
    - _Requirements: 7.1, 7.5, 7.6_

  - [x] 8.2 Implement color mode calculation

    - When state.ison is false, set bgColor to #000000
    - When state.mode is 'color', calculate RGB with gain multiplier
    - Apply gain/100 factor to red, green, blue values
    - Format as rgb(r, g, b) string
    - _Requirements: 7.2, 7.3_

  - [x] 8.3 Implement white mode with Kelvin conversion
    - Create kelvinToRgb(kelvin) helper function
    - Implement temperature-based RGB calculation algorithm
    - For temp ≤ 66: r=255, calculate g using logarithm
    - For temp > 66: calculate r and g using power functions
    - Calculate b based on temperature range
    - Clamp all values to 0-255
    - When state.mode is 'white', convert temp to RGB and apply brightness multiplier
    - _Requirements: 4.5, 7.4_

- [x] 9. Implement API Tester component

  - Create src/components/ApiTester.jsx
  - Use useState for endpoint, method, params, response
  - Render dropdown for endpoint selection with options: /light/0, /color/0, /white/0, /status, /rpc
  - Render dropdown for method selection (GET, POST)
  - Render text input for query parameters
  - Render send button that executes fetch request
  - Build URL with endpoint and params
  - Handle fetch errors and display in response area
  - Display response as formatted JSON using JSON.stringify with indentation
  - Style with semi-transparent white background and border radius
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7_

- [x] 10. Integrate App component and wire everything together

  - Update src/app.jsx to replace default template
  - Use useState for lightState with default values
  - Use useEffect to subscribe to GraphQL on mount
  - Call subscribeLightState with callback that updates local state
  - Return unsubscribe function from useEffect
  - Render Bulb component passing state prop
  - Render ApiTester component
  - Position ApiTester with absolute/fixed positioning over Bulb
  - _Requirements: 10.1, 10.2, 10.3, 10.5_

- [x] 11. Redesign Bulb component with realistic 3D appearance

  - [x] 11.1 Create bulb structure with CSS-based 3D design
    - Update Bulb.jsx to render realistic bulb shape using nested divs
    - Create bulb-container div with relative positioning
    - Create bulb-glass div with border-radius for bulb shape (50% 50% 50% 50% / 60% 60% 40% 40%)
    - Create bulb-glow div for inner light source with dynamic color
    - Create bulb-base div for E27 screw base with metallic gradient
    - Set realistic proportions: container 200px width, 280px height
    - _Requirements: 16.1, 16.2, 16.5_

  - [x] 11.2 Implement visual effects and state-based styling
    - Add radial gradient to bulb-glass for depth and transparency effect
    - Add inset box-shadow to bulb-glass for 3D appearance
    - Apply dynamic background color to bulb-glow based on state
    - Add blur filter to bulb-glow for realistic light diffusion
    - Implement off state: reduce opacity of glow, darken glass
    - Implement on state: full opacity glow, lighter glass appearance
    - Add CSS transitions for smooth state changes
    - _Requirements: 16.3, 16.4, 16.6_

  - [x] 11.3 Update color calculation to work with new bulb structure
    - Modify color calculation logic to set bulb-glow background color
    - Keep existing kelvinToRgb function for white mode
    - Apply gain/brightness multipliers to glow intensity
    - Ensure background color still updates for full-screen effect
    - Test color transitions with new bulb design
    - _Requirements: 16.4, 16.6_

- [x] 12. Implement Color Preset component

  - [x] 12.1 Create ColorPresets component with preset configuration
    - Create src/components/ColorPresets.jsx
    - Define colorPresets array with 8 presets: Red, Green, Blue, Yellow, Purple, Cyan, Warm White, Cool White
    - Each preset object includes: name, rgb/temp values, mode (color/white)
    - Export component function
    - _Requirements: 17.1, 17.4_

  - [x] 12.2 Implement preset button rendering and styling
    - Map over colorPresets array to render buttons
    - Create circular buttons (50px diameter) with border-radius: 50%
    - Set button background color to match preset color
    - Add border: 2px solid rgba(255,255,255,0.3)
    - Apply cursor: pointer and transition effects
    - Add hover effect: transform scale(1.1) and enhanced box-shadow
    - Add active effect: transform scale(0.95)
    - Include aria-label for accessibility
    - _Requirements: 17.5, 17.7, 17.8_

  - [x] 12.3 Implement API calls for preset activation
    - Add onClick handler to each preset button
    - For color mode presets: POST to /color/0 with red, green, blue, turn=on, gain=100
    - For white mode presets: POST to /white/0 with temp, brightness=100, turn=on
    - Use fetch API with method: 'POST'
    - Build query string from preset parameters
    - Handle fetch errors with console.error (no UI error needed due to subscription)
    - _Requirements: 17.2, 17.3, 17.6_

  - [x] 12.4 Style preset container and layout
    - Create container div for preset buttons
    - Use flexbox with flex-direction: row and flex-wrap: wrap
    - Center align buttons with justify-content: center
    - Add gap: 10px between buttons
    - Position container below bulb with margin-top
    - Add responsive styling for smaller screens
    - _Requirements: 17.8_

- [ ] 13. Integrate ColorPresets into App component

  - Update src/app.jsx to import ColorPresets component
  - Render ColorPresets component below Bulb component
  - Adjust layout to accommodate new component without obstruction
  - Update CSS Grid or Flexbox layout if needed
  - Test that preset buttons trigger state updates via subscription
  - Verify bulb updates correctly when presets are clicked
  - _Requirements: 17.1, 17.2, 17.3_


