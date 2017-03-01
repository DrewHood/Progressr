/*
 *	Access interface for PilotEdge XML data.
 */

import SWXMLHash

typealias PilotEdgeStatus = (position: AircraftPosition, flightPlan: FlightPlan, pilotInfo: PilotInfo)

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
		// Grab the latest data.
        if let peData = PilotEdgeRetriever.sharedRetriever.status {
            // Extract data for pilot.
            do {
                let pilot = try peData["status"]["pilots"]["pilot"].withAttr("cid", "\(pilotId)")
                
                print("Ping!")
                
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
                
                debugPrint(pilotInfo)
                debugPrint(aircraftPosition)
                
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
