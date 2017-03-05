import Kitura
import Configuration
import SwiftyJSON

// Load config
let CONFIGURATION = ConfigurationManager()
CONFIGURATION.load(.commandLineArguments)

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

// Set up retriever
try! PilotEdgeRetriever.sharedRetriever.start()

// Load airports
try! AirportDatabase.sharedDatabase.loadAirports() // We want to crash if this fails!

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
