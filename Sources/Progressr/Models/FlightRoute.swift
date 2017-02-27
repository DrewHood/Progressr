/*
 * Flight Route
 */

 enum FlightRouteElementType {
 	case fix
 	case procedure
 }

 struct FlightRouteElement {
 	let type: FlightRouteElementType
 	let name: String
 	let position: Coordinate2D
 }

 struct FlightRoute {
 	// TODO: Implement FlightRoute
 }