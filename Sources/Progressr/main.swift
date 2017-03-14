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
#else
    import Darwin
#endif

// Load config
let CONFIGURATION = ConfigurationManager()
CONFIGURATION.load(.commandLineArguments)

// Init logging
fileprivate let logFilePath = CONFIGURATION["service:logpath"] as? String ?? "/var/log/app/Progressr.log"
LogFile.location = logFilePath
LogFile.debug("Bootstrapped logging to file \(logFilePath)")

////////////////////////////////
// Set up controller and server
if let controller = Controller() {
    Kitura.addHTTPServer(onPort: controller.port, with: controller.router)
} else {
    LogFile.critical("Couldn't init Controller! Quitting!")
    exit(1)
}

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
