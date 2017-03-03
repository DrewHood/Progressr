/*
 *	Access interface for PilotEdge XML data.
 */

import SWXMLHash

struct PilotEdgeStatus {
    let position: AircraftPosition
    let pilotInfo: PilotInfo
    var flightPlan: FlightPlan?
}

extension PilotEdgeStatus: CustomStringConvertible {
    var description: String {
        return "Status... Position: \(self.position); Pilot: \(self.pilotInfo); Plan: \(self.flightPlan)"
    }
}

enum PilotEdgeInterfaceError: Error {
 	case retrievalError
 	case serializationError
}

class PilotEdgeInterface {

	// Singleton
	static let sharedStatus = PilotEdgeInterface()
	private init() {}

	// Internal Interface
	func status(_ pilotId: Int) throws -> PilotEdgeStatus? {
        // TODO: Error handling
        
		// Grab the latest data.
        if let peData = PilotEdgeRetriever.sharedRetriever.status {
            // Extract data for pilot.
            do {
                let pilot = try peData["status"]["pilots"]["pilot"].withAttr("cid", "\(pilotId)")
                
                // Serialize pilot info.
                let pilotInfo = PilotInfo(pilotId: pilotId,
                                          name: pilot["name"].element!.text!,
                                          callsign: pilot["callsign"].element!.text!,
                                          aircraftType: pilot["equipment"].element!.text!)
                
                // Determine the aircraft position
                let positionXml = pilot["position"].element!
                
                let position = Coordinate2D(latitude: Double(positionXml.attribute(by: "lat")!.text)!,
                                            longitude: Double(positionXml.attribute(by: "lon")!.text)!)
                
                let aircraftPosition = AircraftPosition(position: position,
                                                        groundspeed: Float(positionXml.attribute(by: "groundSpeed")!.text)!,
                                                        altitude: Float(positionXml.attribute(by: "alt")!.text)!)
                
                var peStatus = PilotEdgeStatus(position: aircraftPosition, pilotInfo: pilotInfo, flightPlan: nil)
                
                // Parse the flight plan
                if let flightPlanXml = pilot["flightplan"].element {
                    let originAirportCode = flightPlanXml.attribute(by: "origin")?.text ?? "KLAX"
                    let destinationAirportCode = flightPlanXml.attribute(by: "destination")?.text ?? "KPHX"
                    let altitudeStr = flightPlanXml.attribute(by: "altitude")?.text ?? "9999"
                    let altitude = Int(altitudeStr)
                    let type: FlightPlanType = FlightPlanType(rawValue: flightPlanXml.attribute(by: "type")!.text) ?? .vfr
                    
                    // Get the coords
                    let origin = AirportDatabase.sharedDatabase[originAirportCode] ?? AirportDatabase.sharedDatabase["LAX"]
                    let destination = AirportDatabase.sharedDatabase[destinationAirportCode] ?? AirportDatabase.sharedDatabase["PHX"]
                    
                    // Get the route
                    var route = pilot["flightplan"]["route"].element?.text ?? "Couldn't pull route"
                    route = route.replacingOccurrences(of: "<![CDATA[ ", with: "")
                    route = route.replacingOccurrences(of: " ]]>", with: "")
                    
                    
                    // Construct the object
                    let flightPlan = FlightPlan(origin: originAirportCode,
                                                originCoord: origin!.position,
                                                destination: destinationAirportCode,
                                                destinationCoord: destination!.position,
                                                altitude: altitude!,
                                                type: type,
                                                route: route)
                    
                    peStatus.flightPlan = flightPlan
                }
                
                return peStatus
                
            } catch let error as IndexingError {
                print("Index error! \(error.description)")
            } catch {
                print("Unknown parsing error!")
            }
            
            
        } else {
            print("Couldn't retrieve!")
            
            throw PilotEdgeInterfaceError.retrievalError
        }
        
		// Build response object.
		return nil
	}
}
