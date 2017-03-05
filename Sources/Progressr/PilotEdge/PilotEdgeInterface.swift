/*
 *	Access interface for PilotEdge XML data.
 */

import Foundation
import SWXMLHash

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

                var peStatus = PilotEdgeStatus(position: aircraftPosition, pilotInfo: pilotInfo, flightPlan: nil, progress: nil)

                // Parse the flight plan
                if let flightPlanXml = pilot["flightplan"].element {
                    let originAirportCode = flightPlanXml.attribute(by: "origin")?.text ?? "KLAX"
                    let destinationAirportCode = flightPlanXml.attribute(by: "destination")?.text ?? "KPHX"
                    let altitude = flightPlanXml.attribute(by: "altitude")?.text ?? "9999"
                    let type: FlightPlanType = FlightPlanType(rawValue: flightPlanXml.attribute(by: "type")!.text) ?? .vfr

                    // Get the coords
                    let origin = AirportDatabase.sharedDatabase[originAirportCode] ?? AirportDatabase.sharedDatabase["LAX"]
                    let destination = AirportDatabase.sharedDatabase[destinationAirportCode] ?? AirportDatabase.sharedDatabase["PHX"]

                    // Get the route
                    var route = pilot["flightplan"]["route"].element?.text ?? "Couldn't pull route"
                    route = route.replacingOccurrences(of: "<![CDATA[ ", with: "")
                    route = route.replacingOccurrences(of: " ]]>", with: "")


                    // Construct the object
                    let flightPlan = FlightPlan(origin: origin,
                                                destination: destination,
                                                altitude: altitude,
                                                type: type,
                                                route: route)

                    peStatus.flightPlan = flightPlan
                    
                    peStatus.progress = self.generateProgress(origin: flightPlan.origin!, destination: flightPlan.destination!, aircraftPosition: aircraftPosition)
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
    
    private func generateProgress(origin: Airport, destination: Airport, aircraftPosition: AircraftPosition) -> FlightProgress {
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
        var percentComplete = 1.0 - Float32(remainingDistance / totalDistance)
        if percentComplete < 0 { percentComplete = 0 }
        
        // Time
        let minutesRemaining = Int((remainingDistance / Double(aircraftPosition.groundspeed)) * 60)
        
        return FlightProgress(timeRemaining: minutesRemaining, percentComplete: percentComplete)
    }
}
