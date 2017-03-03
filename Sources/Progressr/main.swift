import Kitura

// Create a new router
let router = Router()

// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
}

router.get("/pe/retrieve/:id") {
    request, response, next in
    let pid = request.parameters["id"] ?? "14369"
    
    if let status = try? PilotEdgeInterface.sharedStatus.status(Int(pid)!) {
        response.send(status!.description)
    } else {
        response.send("Failed!")
    }
    
    next()
}

router.get("airport/:code") {
    request, response, next in
    
    // Get code without K
    if let faaCode = request.parameters["code"]?.replacingOccurrences(of: "K", with: "") {
        let airport = AirportDatabase.sharedDatabase[faaCode]
        response.send(airport?.description ?? "Couldn't find airport")
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
