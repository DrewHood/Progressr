/*
 *	Access interface for PilotEdge XML data.
 */

typealias PilotEdgeStatus = (position: AircraftPosition, flightPlan: FlightPlan, pilotInfo: PilotInfo)

enum PilotEdgeInterfaceError {
 	case retrievalError
 	case serializationError
}

class PilotEdgeInterface {

	// Singleton
	static let sharedStatus = PilotEdgeInterface()
	private init() {}

	// Internal Interface
	func status(_ pilotId: Int) throws -> PilotEdgeStatus? {
		// Deserialize the XML.

		// Extract data for pilot.

		// Build response object.
		return nil
	}
}