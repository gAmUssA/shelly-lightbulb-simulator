package com.shelly.simulator

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class ShellySimulatorApplication

fun main(args: Array<String>) {
    runApplication<ShellySimulatorApplication>(*args)
}
