//
//  Controller.swift
//  Progressr
//
//  Created by Drew Hood on 3/14/17.
//
//

import Foundation
import Kitura
import PerfectLogger

class Controller {
    public let router = Router()
    public var port: Int {
        let servicePort = CONFIGURATION["service:port"] as? String ?? "8090"
        return Int(servicePort)!
    }
    
    // Init
    init?() {
        
        do {
            // Set up retriever
            try PilotEdgeRetriever.sharedRetriever.start()
            
            // Load airports
            try AirportDatabase.sharedDatabase.loadAirports()
            
        } catch PilotEdgeInterfaceError.retrievalError {
            LogFile.critical("PE retrieval error!")
            return nil
        } catch AirportDatabaseError.nfdc(let message) {
            LogFile.critical(message ?? "Unknown Airport database error!")
            return nil
        } catch let error {
            LogFile.critical("Unknown error initializing Controller - \(error.localizedDescription)")
            return nil
        }
        
        // Register routes
        self.registerRoutes()
    }
    
    private func registerRoutes() {
        router.get("status/:id", handler: getPeStatus)
        router.get("airport/:code", handler: getAirport)
        
        LogFile.debug("Controller registered routes")
    }
    
    // Route Handlers
    public func getPeStatus(request: RouterRequest, response: RouterResponse, _: @escaping () -> Void) throws {
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        response.headers["Access-Control-Allow-Origin"] = "*"
        
        if let pid = request.parameters["id"] {
            if let status = try PilotEdgeInterface.sharedStatus.status(Int(pid)!) {
                // Convert to JSON.
                try response.status(.OK).send(status.jsonString).end()
            } else {
                try response.status(.notFound).send("{\"error\":\"No pilot with id \(pid).\"}").end()
            }
        } else {
            try response.status(.notAcceptable).send("{\"error\":\"No pilot id provided.\"}").end()
        }
    }
    
    public func getAirport(request: RouterRequest, response: RouterResponse, _: @escaping () -> Void) throws {
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        response.headers["Access-Control-Allow-Origin"] = "*"
        
        // Get code without K
        if var faaCode = request.parameters["code"] {
            if faaCode.characters.count > 3 {
                faaCode.remove(at: faaCode.startIndex)
            }
            
            if let airport = AirportDatabase.sharedDatabase[faaCode.uppercased()] {
                try response.status(.OK).send(airport.jsonString).end()
            } else {
                try response.status(.notFound).send("{\"error\":\"No airport found with code \(faaCode).\"}").end()
            }
        } else {
            try response.status(.notAcceptable).send("{\"error\":\"No airport code provided.\"}").end()
        }
    }
}
