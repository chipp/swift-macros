@attached(extension, names: named(logger))
public macro HasLogger(subsystem: String? = nil, category: String? = nil) =
    #externalMacro(module: "MacrosImplementation", type: "HasLoggerMacro")
