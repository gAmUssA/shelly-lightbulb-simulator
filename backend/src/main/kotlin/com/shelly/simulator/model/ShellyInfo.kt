package com.shelly.simulator.model

/**
 * Response model for the /shelly endpoint following Shelly API v1 specification.
 * Used for device discovery and identification.
 */
data class ShellyInfo(
    /** Device model/type identifier - default is the simulated SHRGBW2 device */
    val type: String = DEFAULT_TYPE,
    /** Device MAC address */
    val mac: String = "B0F1EC000001",
    /** Whether authentication is enabled */
    val auth: Boolean = false,
    /** Firmware version string for the simulated device */
    val fw: String = DEFAULT_FW,
    /** Long device ID format support */
    val longid: Int = 1,
    /** Whether the device is discoverable on the network */
    val discoverable: Boolean = true
) {

    companion object {
        /** Default simulated device type, aligned with DeviceStatus/getConfig identifiers. */
        const val DEFAULT_TYPE: String = "SHRGBW2"

        /** Default simulated firmware version, shared across all endpoints. */
        const val DEFAULT_FW: String = "1.0.0-simulator"
    }
}
