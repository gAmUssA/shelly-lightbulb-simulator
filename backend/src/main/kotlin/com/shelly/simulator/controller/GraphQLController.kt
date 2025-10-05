package com.shelly.simulator.controller

import com.shelly.simulator.model.DeviceStatus
import com.shelly.simulator.model.LightState
import com.shelly.simulator.service.LightService
import kotlinx.coroutines.reactive.asPublisher
import org.springframework.graphql.data.method.annotation.Argument
import org.springframework.graphql.data.method.annotation.MutationMapping
import org.springframework.graphql.data.method.annotation.QueryMapping
import org.springframework.graphql.data.method.annotation.SubscriptionMapping
import org.springframework.stereotype.Controller
import org.reactivestreams.Publisher

@Controller
class GraphQLController(private val lightService: LightService) {
    
    @QueryMapping
    fun lightState(): LightState {
        return lightService.getState()
    }
    
    @QueryMapping
    fun deviceStatus(): DeviceStatus {
        return lightService.getDeviceStatus()
    }
    
    @MutationMapping
    suspend fun setLight(@Argument input: LightInput): LightState {
        val params = mutableMapOf<String, String>()
        
        input.turn?.let { params["turn"] = it }
        input.mode?.let { params["mode"] = it }
        input.red?.let { params["red"] = it.toString() }
        input.green?.let { params["green"] = it.toString() }
        input.blue?.let { params["blue"] = it.toString() }
        input.white?.let { params["white"] = it.toString() }
        input.gain?.let { params["gain"] = it.toString() }
        input.brightness?.let { params["brightness"] = it.toString() }
        input.temp?.let { params["temp"] = it.toString() }
        input.transition?.let { params["transition"] = it.toString() }
        input.effect?.let { params["effect"] = it.toString() }
        
        return lightService.updateState(params)
    }
    
    @MutationMapping
    suspend fun toggleLight(): LightState {
        return lightService.toggle()
    }
    
    @MutationMapping
    suspend fun setEffect(@Argument effect: Int): LightState {
        val params = mapOf("effect" to effect.toString())
        return lightService.updateState(params)
    }
    
    @SubscriptionMapping
    fun lightStateChanged(): Publisher<LightState> {
        return lightService.getStateFlow().asPublisher()
    }
}

data class LightInput(
    val turn: String? = null,
    val mode: String? = null,
    val red: Int? = null,
    val green: Int? = null,
    val blue: Int? = null,
    val white: Int? = null,
    val gain: Int? = null,
    val brightness: Int? = null,
    val temp: Int? = null,
    val transition: Int? = null,
    val effect: Int? = null
)
