package com.shelly.simulator.service

import com.shelly.simulator.model.DeviceStatus
import com.shelly.simulator.model.LightMode
import com.shelly.simulator.model.LightState
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import org.springframework.stereotype.Service
import java.time.Instant

@Service
class LightService {
    private val startTime = Instant.now()
    private val state = LightState()
    private val _stateFlow = MutableSharedFlow<LightState>(replay = 1)
    
    init {
        // Emit initial state to the flow so subscribers get the current state immediately
        kotlinx.coroutines.runBlocking {
            _stateFlow.emit(state.copy())
        }
    }
    
    fun getState(): LightState = state.copy()
    
    fun getDeviceStatus(): DeviceStatus {
        val uptime = Instant.now().epochSecond - startTime.epochSecond
        return DeviceStatus(
            light = state.copy(),
            uptime = uptime
        )
    }
    
    fun getStateFlow(): SharedFlow<LightState> = _stateFlow.asSharedFlow()
    
    suspend fun updateState(params: Map<String, String>): LightState {
        // Handle turn parameter
        params["turn"]?.let { turn ->
            when (turn.lowercase()) {
                "on" -> state.ison = true
                "off" -> state.ison = false
                "toggle" -> state.ison = !state.ison
            }
        }
        
        // Handle mode parameter
        params["mode"]?.let { mode ->
            when (mode.uppercase()) {
                "COLOR" -> state.mode = LightMode.COLOR
                "WHITE" -> state.mode = LightMode.WHITE
            }
        }
        
        // Handle color parameters with coercion
        params["red"]?.toIntOrNull()?.let { state.red = it.coerceIn(0, 255) }
        params["green"]?.toIntOrNull()?.let { state.green = it.coerceIn(0, 255) }
        params["blue"]?.toIntOrNull()?.let { state.blue = it.coerceIn(0, 255) }
        params["white"]?.toIntOrNull()?.let { state.white = it.coerceIn(0, 255) }
        params["gain"]?.toIntOrNull()?.let { state.gain = it.coerceIn(0, 100) }
        
        // Handle white mode parameters with coercion
        params["brightness"]?.toIntOrNull()?.let { state.brightness = it.coerceIn(0, 100) }
        params["temp"]?.toIntOrNull()?.let { state.temp = it.coerceIn(3000, 6500) }
        
        // Handle transition parameter with coercion
        params["transition"]?.toIntOrNull()?.let { state.transition = it.coerceIn(0, 5000) }
        
        // Handle effect parameter with coercion
        params["effect"]?.toIntOrNull()?.let { state.effect = it.coerceIn(0, 6) }
        
        // Set source to http
        state.source = "http"
        
        // Emit updated state to SharedFlow
        _stateFlow.emit(state.copy())
        
        return state.copy()
    }
    
    suspend fun updateStateFromRpc(params: Map<String, Any>): LightState {
        // Handle rgb array parameter
        (params["rgb"] as? List<*>)?.let { rgb ->
            if (rgb.size >= 3) {
                (rgb[0] as? Number)?.toInt()?.let { state.red = it.coerceIn(0, 255) }
                (rgb[1] as? Number)?.toInt()?.let { state.green = it.coerceIn(0, 255) }
                (rgb[2] as? Number)?.toInt()?.let { state.blue = it.coerceIn(0, 255) }
            }
        }
        
        // Handle on boolean parameter mapping to ison
        (params["on"] as? Boolean)?.let { state.ison = it }
        
        // Handle brightness parameter
        (params["brightness"] as? Number)?.toInt()?.let { state.brightness = it.coerceIn(0, 100) }
        
        // Handle white parameter
        (params["white"] as? Number)?.toInt()?.let { state.white = it.coerceIn(0, 255) }
        
        // Set source to rpc
        state.source = "rpc"
        
        // Emit updated state to SharedFlow
        _stateFlow.emit(state.copy())
        
        return state.copy()
    }
    
    suspend fun toggle(): LightState {
        state.ison = !state.ison
        state.source = "rpc"
        
        // Emit state change
        _stateFlow.emit(state.copy())
        
        return state.copy()
    }
    
    fun getConfig(): Map<String, Any> {
        return mapOf(
            "deviceId" to "shellysimulator-001",
            "deviceType" to "SHRGBW2",
            "firmware" to "1.0.0-simulator",
            "mode" to state.mode.name,
            "transition" to state.transition,
            "effect" to state.effect
        )
    }
}
