import Foundation

struct PilotEdgeStatus {
    let position: AircraftPosition
    let pilotInfo: PilotInfo
    var flightPlan: FlightPlan? = nil
    var progress: FlightProgress? = nil
    
    init(position: AircraftPosition, pilotInfo: PilotInfo) {
        self.position = position
        self.pilotInfo = pilotInfo
        self.flightPlan = nil
        self.progress = nil
    }
}

extension PilotEdgeStatus: CustomStringConvertible {
    var description: String {
        return "Status... Position: \(self.position); Pilot: \(self.pilotInfo); Plan: \(self.flightPlan); Progress: \(self.progress)"
    }
}

extension PilotEdgeStatus: JSONStringConvertible {
    var jsonString: String {
        let flightPlanString = self.flightPlan?.jsonString ?? "null"
        let flightProgressString = self.progress?.jsonString ?? "null"
        
        return "{\"position\":\(self.position.jsonString),\"pilot\":\(self.pilotInfo.jsonString),\"flightPlan\":\(flightPlanString), \"progress\":\(flightProgressString)}"
    }
}
