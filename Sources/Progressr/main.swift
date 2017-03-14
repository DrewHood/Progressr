import Kitura
import Configuration
import SwiftyJSON
import PerfectLogger

// Linux support
#if os(Linux)
    import Glibc
    
    enum Signal:Int32 {
        case HUP    = 1
        case INT    = 2
        case QUIT   = 3
        case ABRT   = 6
        case KILL   = 9
        case ALRM   = 14
        case TERM   = 15
    }
#endif

// Load config
let CONFIGURATION = ConfigurationManager()
CONFIGURATION.load(.commandLineArguments)

// Init logging
fileprivate let logFilePath = CONFIGURATION["service:logpath"] as? String ?? "/var/log/app/Progressr.log"
LogFile.location = logFilePath
LogFile.debug("Bootstrapped logging to file \(logFilePath)")

// Create a new router
let router = Router()

router.get("/pe/status/:id") {
    request, response, next in
    
    if let pid = request.parameters["id"] {
        if let status = try PilotEdgeInterface.sharedStatus.status(Int(pid)!) {
            // Convert to JSON.
            response.send(status.jsonString)
        } else {
            response.status(.notFound)
            response.send("{\"error\":\"No pilot with id \(pid).\"}")
        }
    } else {
        response.status(.notAcceptable)
        response.send("{\"error\":\"No pilot id provided.\"}")
    }

    next()
}

router.get("airport/:code") {
    request, response, next in

    // Get code without K
    if var faaCode = request.parameters["code"] {
        if faaCode.characters.count > 3 {
            faaCode.remove(at: faaCode.startIndex)
        }
        
        if let airport = AirportDatabase.sharedDatabase[faaCode] {
            response.send(airport.jsonString)
        } else {
            response.status(.notFound).send("{\"error\":\"No airport found with code \(faaCode).\"}")
        }
    } else {
        response.status(.notAcceptable).send("{\"error\":\"No airport code provided.\"}")
    }

    next()
}

do {
    // Set up retriever
    try PilotEdgeRetriever.sharedRetriever.start()
    
    // Load airports
    try AirportDatabase.sharedDatabase.loadAirports() // We want to crash if this fails!
    
    // Add an HTTP server and connect it to the router
    let servicePort = CONFIGURATION["service:port"] as? String ?? "8090"
    LogFile.info("Starting service on port \(servicePort)")
    
    Kitura.addHTTPServer(onPort: Int(servicePort)!, with: router)
    
    #if os(Linux)
        
        typealias SigactionHandler = @convention(c)(Int32) -> Void
        
        func trap(signum:Signal, action: @escaping SigactionHandler) {
            signal(signum.rawValue, action)
        }
        
        let termHandler: SigactionHandler = { signal in
            LogFile.info("Received SIGTERM. Closing servers and shutting down.")
            
            // Stop calling PE
            PilotEdgeRetriever.sharedRetriever.stop()
            
            Kitura.stop()
            
            exit(0)
        }
        
        trap(signum: .TERM, action: termHandler)
        trap(signum: .INT, action: termHandler)
        
        Kitura.start()
        
        select(0, nil, nil, nil, nil)
        
    #else
        // Start the Kitura runloop (this call never returns)
        Kitura.run()
    #endif

} catch PilotEdgeRetrieverError.networkFailure {
    LogFile.critical("PE Network failure!")
} catch PilotEdgeInterfaceError.retrievalError {
    LogFile.critical("PE retrieval error!")
} catch AirportDatabaseError.nfdc(let message) {
    LogFile.critical(message ?? "Unknown Airport database error!")
} catch {
    LogFile.critical("Unknown error starting service!")
}
