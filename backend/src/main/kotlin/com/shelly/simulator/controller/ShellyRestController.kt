package com.shelly.simulator.controller

import com.shelly.simulator.model.*
import com.shelly.simulator.service.LightService
import kotlinx.coroutines.runBlocking
import org.springframework.web.bind.annotation.*

@RestController
@CrossOrigin(origins = ["*"])
class ShellyRestController(private val lightService: LightService) {
    
    @GetMapping("/light/{id}")
    fun getLightState(
        @PathVariable id: String,
        @RequestParam(required = false) params: Map<String, String>?
    ): LightState = runBlocking {
        if (params.isNullOrEmpty()) {
            lightService.getState()
        } else {
            lightService.updateState(params)
        }
    }
    
    @PostMapping("/light/{id}")
    fun updateLightState(
        @PathVariable id: String,
        @RequestParam params: Map<String, String>
    ): LightState = runBlocking {
        lightService.updateState(params)
    }
    
    @GetMapping("/color/{id}")
    fun getColorState(
        @PathVariable id: String,
        @RequestParam(required = false) params: Map<String, String>?
    ): LightState = runBlocking {
        if (params.isNullOrEmpty()) {
            lightService.getState()
        } else {
            val mutableParams = params.toMutableMap()
            mutableParams["mode"] = "COLOR"
            lightService.updateState(mutableParams)
        }
    }
    
    @PostMapping("/color/{id}")
    fun updateColorState(
        @PathVariable id: String,
        @RequestParam params: Map<String, String>
    ): LightState = runBlocking {
        val mutableParams = params.toMutableMap()
        mutableParams["mode"] = "COLOR"
        lightService.updateState(mutableParams)
    }
    
    @GetMapping("/white/{id}")
    fun getWhiteState(
        @PathVariable id: String,
        @RequestParam(required = false) params: Map<String, String>?
    ): LightState = runBlocking {
        if (params.isNullOrEmpty()) {
            lightService.getState()
        } else {
            val mutableParams = params.toMutableMap()
            mutableParams["mode"] = "WHITE"
            lightService.updateState(mutableParams)
        }
    }
    
    @PostMapping("/white/{id}")
    fun updateWhiteState(
        @PathVariable id: String,
        @RequestParam params: Map<String, String>
    ): LightState = runBlocking {
        val mutableParams = params.toMutableMap()
        mutableParams["mode"] = "WHITE"
        lightService.updateState(mutableParams)
    }
    
    @GetMapping("/status")
    fun getStatus(): DeviceStatus {
        return lightService.getDeviceStatus()
    }
    
    @GetMapping("/settings")
    fun getSettings(): Map<String, Any> {
        return lightService.getConfig()
    }
    
    @PostMapping("/rpc")
    fun handleRpc(@RequestBody request: RpcRequest): RpcResponse = runBlocking {
        try {
            val result = when (request.method) {
                "RGBW.Set" -> {
                    val params = request.params ?: emptyMap()
                    lightService.updateStateFromRpc(params)
                }
                "RGBW.Toggle" -> {
                    lightService.toggle()
                }
                "RGBW.GetStatus" -> {
                    lightService.getState()
                }
                "RGBW.GetConfig" -> {
                    lightService.getConfig()
                }
                else -> {
                    return@runBlocking RpcResponse(
                        id = request.id,
                        result = null,
                        error = RpcError(
                            code = -32601,
                            message = "Method not found: ${request.method}"
                        )
                    )
                }
            }
            
            RpcResponse(
                id = request.id,
                result = result,
                error = null
            )
        } catch (e: Exception) {
            RpcResponse(
                id = request.id,
                result = null,
                error = RpcError(
                    code = -32603,
                    message = "Internal error: ${e.message}"
                )
            )
        }
    }
}
