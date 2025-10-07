# Requirements Document

## Introduction

This project is a web-based simulator that emulates the Shelly RGBW2 smart lightbulb REST API. The simulator provides a visual representation of a virtual light bulb that responds to API calls in real-time, allowing developers to test Shelly API integrations without physical hardware. The system supports both Gen1 and Gen2 Shelly API formats, includes GraphQL subscriptions for real-time updates, and features a Preact-based frontend that displays the bulb's current state through dynamic color changes.

## Requirements

### Requirement 1: REST API Endpoint Support

**User Story:** As an API consumer, I want to control the virtual light bulb using standard Shelly REST API endpoints, so that I can test my Shelly integration code without physical hardware.

#### Acceptance Criteria

1. WHEN a GET request is made to `/light/0` THEN the system SHALL return the current light state including all properties (ison, mode, color values, brightness, temperature, transition, effect)
2. WHEN a POST request is made to `/light/0` with query parameters THEN the system SHALL update the light state according to the provided parameters and return the updated state
3. WHEN a GET request is made to `/color/0` THEN the system SHALL return the current light state
4. WHEN a POST request is made to `/color/0` with query parameters THEN the system SHALL set the mode to COLOR and update the state accordingly
5. WHEN a GET request is made to `/white/0` THEN the system SHALL return the current light state
6. WHEN a POST request is made to `/white/0` with query parameters THEN the system SHALL set the mode to WHITE and update the state accordingly
7. WHEN a GET request is made to `/status` THEN the system SHALL return the complete device status including device metadata and current light state
8. WHEN a GET request is made to `/settings` THEN the system SHALL return device configuration settings

### Requirement 2: Gen2 RPC API Support

**User Story:** As an API consumer, I want to use Gen2 style RPC endpoints to control the light bulb, so that I can test both legacy and modern Shelly API formats.

#### Acceptance Criteria

1. WHEN a POST request is made to `/rpc` with method `RGBW.Set` THEN the system SHALL update the light state with the provided parameters and return the updated state
2. WHEN a POST request is made to `/rpc` with method `RGBW.Toggle` THEN the system SHALL toggle the light on/off state and return the updated state
3. WHEN a POST request is made to `/rpc` with method `RGBW.GetStatus` THEN the system SHALL return the current light state
4. WHEN a POST request is made to `/rpc` with method `RGBW.GetConfig` THEN the system SHALL return the device configuration
5. WHEN a POST request is made to `/rpc` with an unsupported method THEN the system SHALL return an RPC error response with code -32601 and message "Method not found"
6. WHEN an RPC request includes an id field THEN the system SHALL include the same id in the response

### Requirement 3: Color Mode Control

**User Story:** As an API consumer, I want to control the light bulb in color mode using RGB and white channel values, so that I can create custom colors and lighting effects.

#### Acceptance Criteria

1. WHEN color mode is active AND red parameter is provided (0-255) THEN the system SHALL update the red channel value within the valid range
2. WHEN color mode is active AND green parameter is provided (0-255) THEN the system SHALL update the green channel value within the valid range
3. WHEN color mode is active AND blue parameter is provided (0-255) THEN the system SHALL update the blue channel value within the valid range
4. WHEN color mode is active AND white parameter is provided (0-255) THEN the system SHALL update the white channel value within the valid range
5. WHEN color mode is active AND gain parameter is provided (0-100) THEN the system SHALL update the overall brightness multiplier within the valid range
6. WHEN a color parameter value exceeds the valid range THEN the system SHALL coerce it to the nearest valid value
7. WHEN the mode is set to COLOR THEN the system SHALL use RGB and white channel values to determine the output color

### Requirement 4: White Mode Control

**User Story:** As an API consumer, I want to control the light bulb in white mode using brightness and color temperature, so that I can simulate different white light conditions.

#### Acceptance Criteria

1. WHEN white mode is active AND brightness parameter is provided (0-100) THEN the system SHALL update the brightness value within the valid range
2. WHEN white mode is active AND temp parameter is provided (3000-6500K) THEN the system SHALL update the color temperature value within the valid range
3. WHEN a white mode parameter value exceeds the valid range THEN the system SHALL coerce it to the nearest valid value
4. WHEN the mode is set to WHITE THEN the system SHALL use brightness and temperature values to determine the output color
5. WHEN color temperature is set THEN the system SHALL convert the Kelvin value to an appropriate RGB representation

### Requirement 5: Power State Control

**User Story:** As an API consumer, I want to turn the light bulb on, off, or toggle its state, so that I can control the basic power functionality.

#### Acceptance Criteria

1. WHEN turn parameter is "on" THEN the system SHALL set ison to true
2. WHEN turn parameter is "off" THEN the system SHALL set ison to false
3. WHEN turn parameter is "toggle" THEN the system SHALL invert the current ison value
4. WHEN ison is false THEN the visual representation SHALL display as completely dark regardless of color settings
5. WHEN ison is true THEN the visual representation SHALL display the configured color based on the current mode

### Requirement 6: Transition Effects

**User Story:** As an API consumer, I want to specify transition durations for color changes, so that I can create smooth lighting animations.

#### Acceptance Criteria

1. WHEN transition parameter is provided (0-5000ms) THEN the system SHALL update the transition duration within the valid range
2. WHEN a transition value exceeds the valid range THEN the system SHALL coerce it to the nearest valid value
3. WHEN the light state changes THEN the visual representation SHALL animate the color change over the specified transition duration
4. WHEN no transition parameter is provided THEN the system SHALL use the current transition value (default 500ms)

### Requirement 7: Visual Bulb Representation

**User Story:** As a user viewing the simulator, I want to see a visual representation of the light bulb that reflects its current state and color, so that I can immediately understand the effect of API calls.

#### Acceptance Criteria

1. WHEN the light state changes THEN the webpage background color SHALL update to reflect the current bulb color
2. WHEN the light is off THEN the background SHALL be black (#000000)
3. WHEN the light is in color mode THEN the background SHALL display RGB values adjusted by the gain multiplier
4. WHEN the light is in white mode THEN the background SHALL display the color temperature converted to RGB and adjusted by brightness
5. WHEN a transition duration is set THEN the color change SHALL animate smoothly over that duration
6. WHEN the page loads THEN a circular bulb element SHALL be displayed in the center with a glow effect matching the current color

### Requirement 8: GraphQL Query Support

**User Story:** As an API consumer, I want to query the light state using GraphQL, so that I can retrieve specific fields efficiently.

#### Acceptance Criteria

1. WHEN a GraphQL query for `lightState` is executed THEN the system SHALL return all current light state properties
2. WHEN a GraphQL query for `deviceStatus` is executed THEN the system SHALL return device metadata and current light state
3. WHEN a GraphQL query requests specific fields THEN the system SHALL return only the requested fields
4. WHEN a GraphQL query is malformed THEN the system SHALL return an appropriate GraphQL error response

### Requirement 9: GraphQL Mutation Support

**User Story:** As an API consumer, I want to modify the light state using GraphQL mutations, so that I can use a modern API approach for control.

#### Acceptance Criteria

1. WHEN a `setLight` mutation is executed with input parameters THEN the system SHALL update the light state accordingly and return the updated state
2. WHEN a `toggleLight` mutation is executed THEN the system SHALL toggle the on/off state and return the updated state
3. WHEN a `setEffect` mutation is executed with an effect number THEN the system SHALL update the effect value and return the updated state
4. WHEN a mutation includes invalid parameters THEN the system SHALL return an appropriate GraphQL error response

### Requirement 10: Real-Time State Synchronization

**User Story:** As a frontend client, I want to receive real-time updates when the light state changes, so that the visual representation stays synchronized with API calls from any source.

#### Acceptance Criteria

1. WHEN a client subscribes to `lightStateChanged` via GraphQL WebSocket THEN the system SHALL establish a WebSocket connection
2. WHEN the light state changes through any API endpoint THEN the system SHALL emit the updated state to all subscribed clients
3. WHEN a state change occurs THEN subscribed clients SHALL receive the update within 100ms
4. WHEN a WebSocket connection is lost THEN the client SHALL attempt to reconnect automatically
5. WHEN multiple clients are subscribed THEN all clients SHALL receive state updates simultaneously

### Requirement 11: API Testing Interface

**User Story:** As a developer testing the simulator, I want a built-in API testing interface, so that I can quickly test different API calls without external tools.

#### Acceptance Criteria

1. WHEN the frontend loads THEN an API tester component SHALL be visible on the page
2. WHEN a user selects an endpoint from a dropdown THEN the endpoint path SHALL be populated
3. WHEN a user selects an HTTP method THEN the method SHALL be set for the request
4. WHEN a user enters query parameters THEN the parameters SHALL be included in the request
5. WHEN a user clicks the send button THEN the API request SHALL be executed and the response SHALL be displayed
6. WHEN an API request fails THEN the error message SHALL be displayed in the response area
7. WHEN a response is received THEN it SHALL be formatted as readable JSON

### Requirement 12: Effect Support

**User Story:** As an API consumer, I want to set lighting effects on the bulb, so that I can simulate dynamic lighting patterns.

#### Acceptance Criteria

1. WHEN effect parameter is provided (0-6) THEN the system SHALL update the effect value within the valid range
2. WHEN effect is 0 THEN no special effect SHALL be active
3. WHEN effect is 1-6 THEN the system SHALL store the effect value in the state
4. WHEN an effect value exceeds the valid range THEN the system SHALL coerce it to the nearest valid value
5. WHEN the effect value changes THEN the updated value SHALL be included in state responses

### Requirement 13: CORS Support

**User Story:** As a developer integrating with the simulator from a web application, I want CORS to be enabled, so that I can make API calls from different origins.

#### Acceptance Criteria

1. WHEN an API request is made from any origin THEN the system SHALL include appropriate CORS headers in the response
2. WHEN a preflight OPTIONS request is made THEN the system SHALL respond with allowed methods and headers
3. WHEN CORS headers are set THEN they SHALL allow all origins, methods, and headers for development purposes

### Requirement 14: State Persistence

**User Story:** As a user of the simulator, I want the light state to persist during the application runtime, so that the bulb maintains its configuration across multiple API calls.

#### Acceptance Criteria

1. WHEN the application starts THEN the system SHALL initialize with default light state values
2. WHEN the light state is modified THEN the new state SHALL be stored in memory
3. WHEN subsequent API calls are made THEN they SHALL operate on the current persisted state
4. WHEN the application restarts THEN the state SHALL reset to default values

### Requirement 15: Parameter Validation

**User Story:** As an API consumer, I want invalid parameters to be handled gracefully, so that the system remains stable and provides clear feedback.

#### Acceptance Criteria

1. WHEN a numeric parameter is provided as a non-numeric string THEN the system SHALL ignore that parameter
2. WHEN a parameter value is outside the valid range THEN the system SHALL coerce it to the nearest valid boundary
3. WHEN an unknown parameter is provided THEN the system SHALL ignore it without error
4. WHEN required RPC parameters are missing THEN the system SHALL return an appropriate error response
5. WHEN the light state is updated THEN all values SHALL remain within their defined valid ranges

### Requirement 16: Realistic Bulb Visual Design

**User Story:** As a user viewing the simulator, I want the bulb component to visually resemble an actual Shelly smart bulb, so that the simulator provides a more realistic and engaging experience.

#### Acceptance Criteria

1. WHEN the page loads THEN the bulb SHALL be rendered with a 3D appearance resembling a physical light bulb
2. WHEN the bulb is on THEN it SHALL display a realistic bulb shape with appropriate lighting effects
3. WHEN the bulb is off THEN it SHALL display a dimmed or dark bulb appearance
4. WHEN the color changes THEN the bulb's glow and color SHALL transition smoothly
5. WHEN the bulb is displayed THEN it SHALL include visual elements such as a bulb base, glass envelope, and realistic proportions
6. WHEN the bulb state changes THEN the visual representation SHALL maintain the bulb-like appearance throughout transitions
7. WHEN the bulb is displayed THEN only the bulb component SHALL emit light and glow, not the entire page background
8. WHEN the bulb is on THEN the glow effect SHALL be contained to the bulb area with a radial gradient extending outward from the bulb
9. WHEN the page background is visible THEN it SHALL remain a neutral dark color regardless of bulb state

### Requirement 17: Quick Color Preset Buttons

**User Story:** As a user testing the simulator, I want quick access buttons for common colors, so that I can rapidly test different color states without manually entering RGB values.

#### Acceptance Criteria

1. WHEN the UI loads THEN a set of color preset buttons SHALL be visible on the interface
2. WHEN a color preset button is clicked THEN the system SHALL send an API request to change the bulb to that color
3. WHEN a color preset is applied THEN the bulb SHALL update to display the selected color
4. WHEN preset buttons are displayed THEN they SHALL include at least 5-8 common colors (e.g., red, green, blue, yellow, purple, white, warm white, cool white)
5. WHEN a preset button is rendered THEN it SHALL visually indicate the color it represents
6. WHEN a preset button is clicked THEN the API call SHALL use the appropriate endpoint (/color/0 or /white/0) based on the color type
7. WHEN a preset button is clicked THEN the button SHALL provide visual feedback (e.g., hover effect, active state)
8. WHEN preset buttons are arranged THEN they SHALL be positioned in an accessible location that doesn't obstruct the bulb view
