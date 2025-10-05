package com.shelly.simulator.model

data class DeviceStatus(
    val deviceId: String = "shellysimulator-001",
    val deviceType: String = "SHRGBW2",
    val firmware: String = "1.0.0-simulator",
    val light: LightState,
    val uptime: Long,
    val hasUpdate: Boolean = false
)
