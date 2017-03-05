/*
 *	Flight Plan
 */

enum FlightPlanType: String {
 	case vfr = "VFR"
 	case ifr = "IFR"
 }

 struct FlightPlan {
 	let origin: Airport?
 	let destination: Airport?
 	let altitude: String
 	let type: FlightPlanType
 	let route: String
 }

extension FlightPlan: CustomStringConvertible {
    var description: String {
        return "\(self.origin?.code) -> \(self.destination?.code), \"\(self.altitude)\", \(self.type).\n\(self.route)"
    }
}

extension FlightPlan: JSONStringConvertible {
    var jsonString: String {
        let originStr = self.origin?.jsonString ?? "null"
        let destinationStr = self.destination?.jsonString ?? "null"
        return "{\"origin\":\(originStr),\"destination\":\(destinationStr),\"altitude\":\"\(self.altitude)\",\"type\":\"\(self.type.rawValue)\",\"route\":\"\(self.route)\"}"
    }
}
