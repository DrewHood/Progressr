/*
 *	Flight Plan
 */

enum FlightPlanType: String {
 	case vfr = "VFR"
 	case ifr = "IFR"
 }

 struct FlightPlan {
 	let origin: String
 	let originCoord: Coordinate2D
 	let destination: String
 	let destinationCoord: Coordinate2D
 	let altitude: Int
 	let trueAirspeed: Int
 	let type: FlightPlanType
 	let route: String
 }

extension FlightPlan: CustomStringConvertible {
    var description: String {
        return "\(self.origin) (\(self.originCoord) -> \(self.destination) (\(self.destinationCoord)), \(self.altitude), \(self.trueAirspeed), \(self.type).\n\(self.route)"
    }
}
