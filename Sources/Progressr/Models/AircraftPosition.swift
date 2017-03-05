/*
 *	Aircraft Position
 */

struct AircraftPosition {
    let position: Coordinate2D
    let groundspeed: Float
    let altitude: Float
}

extension AircraftPosition: CustomStringConvertible {
    var description: String {
        return "Aircraft position: \(self.position); GS: \(self.groundspeed); Alt: \(self.altitude)"
    }
}

extension AircraftPosition: JSONStringConvertible {
    var jsonString: String {
        return "{\"position\":\(self.position.jsonString),\"groundspeed\":\(self.groundspeed),\"altitude\":\(self.altitude)}"
    }
}
