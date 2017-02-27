/*
 *	Flight Plan
 */

 enum FlightPlanType {
 	case vfr
 	case ifr
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