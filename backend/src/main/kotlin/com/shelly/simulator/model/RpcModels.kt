package com.shelly.simulator.model

data class RpcRequest(
    val id: Int?,
    val method: String,
    val params: Map<String, Any>?
)

data class RpcResponse(
    val id: Int?,
    val result: Any?,
    val error: RpcError? = null
)

data class RpcError(
    val code: Int,
    val message: String
)
