/*
 * Pilot Info
 */

struct PilotInfo {
	let pilotId: Int
	let name: String
	let callsign: String
	let aircraftType: String
}

extension PilotInfo: CustomStringConvertible {
    var description: String {
        return "Pilot id: \(self.pilotId)\nName: \(self.name)\nCallsign: \(self.callsign)\nType: \(self.aircraftType)"
    }
}
