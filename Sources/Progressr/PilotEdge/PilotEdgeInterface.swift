/*
 *	Access interface for PilotEdge XML data.
 */

import Foundation
import PerfectXML
import PerfectLogger

enum PilotEdgeInterfaceError: Error {
    case retrievalError
    case serializationError(message: String)
}

class PilotEdgeInterface {
    
    // Singleton
    static let sharedStatus = PilotEdgeInterface()
    private init() {}
    
    // Internal Interface
    func status(_ pilotId: Int) throws -> PilotEdgeStatus? {
        // Get the pilot
        guard let pilot = self.retrievePilotXML(pilotId) else { return nil }
        
        // Build pilot info object
        guard let pIdStr = pilot.getAttribute(name: "cid")  else { throw PilotEdgeInterfaceError.serializationError(message: "Couldn't serialize pilot info") }
        let pName = pilot.childValue("name")!
        let pCallsign = pilot.childValue("callsign")!
        let pType = pilot.childValue("equipment")!
        
        let pilotInfo = PilotInfo(pilotId: Int(pIdStr)!, name: pName, callsign: pCallsign, aircraftType: pType)
        
        // Build position object. 
        guard let posXml = pilot.childNode("position") else { throw PilotEdgeInterfaceError.serializationError(message: "Couldn't serialize 'position'") }
        let latXml = posXml.getAttribute(name: "lat")!
        let lonXml = posXml.getAttribute(name: "lon")!
        let speedXml = posXml.getAttribute(name: "groundSpeed")!
        let altXml = posXml.getAttribute(name: "alt")!
        
        let positionCoord = Coordinate2D(latitude: Double(latXml)!, longitude: Double(lonXml)!)
        let acPosition = AircraftPosition(position: positionCoord, groundspeed: Float(speedXml)!, altitude: Float(altXml)!)
        
        // Construct the PE Status object.
        var peStatus = PilotEdgeStatus(position: acPosition, pilotInfo: pilotInfo)
        
        // Flight plan. 
        if let routeXml = pilot.childNode("flightplan")?.childNode("route") { // workaround: library picks up on <flightplan/> stubs.
            let flightPlanXml = pilot.childNode("flightplan")!
            
            let originCode = flightPlanXml.getAttribute(name: "origin")!
            let destinationCode = flightPlanXml.getAttribute(name: "destination")!
            
            // Construct orig/dest airports
            guard let origin = AirportDatabase.sharedDatabase[originCode] else { throw AirportDatabaseError.unknown }
            guard let destination = AirportDatabase.sharedDatabase[destinationCode] else { throw AirportDatabaseError.unknown }
            
            // Other info
            let type = FlightPlanType(rawValue: flightPlanXml.getAttribute(name: "type")!)!
            let alt = flightPlanXml.getAttribute(name: "altitude")!
            let route = routeXml.nodeValue!
            
            // Construct flight plan object
            peStatus.flightPlan = FlightPlan(origin: origin,
                                             destination: destination,
                                             altitude: alt,
                                             type: type,
                                             route: route)
            
            // Because we have a flight plan, we can determine progress
            peStatus.progress = self.generateProgress(origin: origin,
                                                      destination: destination,
                                                      aircraftPosition: acPosition)
            
        }
        
        // Build response object.
        return peStatus
    }
    
    private func generateProgress(origin: Airport, destination: Airport, aircraftPosition: AircraftPosition) -> FlightProgress {
        // TODO: Move this func out to the Coordinate2D object
        func calculateDistance(_ from: Coordinate2D, _ to: Coordinate2D) -> Double {
            let startLat = from.latitude
            let startLon = from.longitude
            
            let endLat = to.latitude
            let endLon = to.longitude
            
            let R: Double = 3437.73877 //  modifier to convert to nautical miles
            
            let dLat = (endLat - startLat).toRadian()
            let dLon = (endLon - startLon).toRadian()
            
            let lat1 = startLat.toRadian()
            let lat2 = endLat.toRadian()
            
            let a = sin(dLat / 2) * sin(dLat / 2) + sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2)
            let c = 2 * atan2(sqrt(a), sqrt(1 - a))
            return R * c
        }
        
        let totalDistance = calculateDistance(origin.position, destination.position)
        let remainingDistance = calculateDistance(aircraftPosition.position, destination.position)
        
        // Percent
        var percentComplete = (1.0 - Float32(remainingDistance / totalDistance)) * 100.00
        if percentComplete < 0 { percentComplete = 0 }
        
        // Time
        let secondsRemaining = remainingDistance / Double(aircraftPosition.groundspeed)
        let minutesRemaining = Int(secondsRemaining) * 60
        
        return FlightProgress(timeRemaining: minutesRemaining, percentComplete: percentComplete)
    }
    
    private func retrievePilotXML(_ pilotId: Int) -> XElement? {
        guard let peData = PilotEdgeRetriever.sharedRetriever.status else { LogFile.error("No status!"); return nil }
        
        // This returns a NodeSet. If pilot n/a, will be empty.
        let setRes = peData.extract(path: "/status/pilots/pilot[@cid=\(pilotId)]")
        guard case .nodeSet (let pilotSet) = setRes else { return nil }
        
        if pilotSet.count == 1 { // We require a unique result
            for pilot in pilotSet {
                guard let pilotXML = pilot as? XElement else { return nil }
                return pilotXML
            }
        } else { return nil }
        
        return nil
    }
}
