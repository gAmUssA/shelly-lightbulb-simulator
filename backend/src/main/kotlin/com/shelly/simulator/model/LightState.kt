package com.shelly.simulator.model

enum class LightMode {
    COLOR, WHITE
}

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
    var source: String = "http"
)
