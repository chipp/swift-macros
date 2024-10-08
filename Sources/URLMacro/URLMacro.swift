@freestanding(expression)
public macro url(subsystem: String? = nil, category: String? = nil) =
    #externalMacro(module: "MacrosImplementation", type: "URLMacro")
