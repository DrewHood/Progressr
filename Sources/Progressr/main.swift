import Kitura

// Create a new router
let router = Router()

// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
}

router.get("/pe/retrieve") {
    request, response, next in
    try! PilotEdgeRetriever.sharedRetriever.retrieveOnce()
    
    let pid = request.parameters["id"] ?? "4039"
    
    if pid != nil {
        try! PilotEdgeInterface.sharedStatus.status(Int(pid)!)
    }
    
    response.send("Done")
    next()
}

// Set up retriever
try! PilotEdgeRetriever.sharedRetriever.start()

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
