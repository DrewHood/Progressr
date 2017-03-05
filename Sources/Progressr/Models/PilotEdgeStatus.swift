import Foundation

struct PilotEdgeStatus {
    let position: AircraftPosition
    let pilotInfo: PilotInfo
    var flightPlan: FlightPlan?
    var progress: FlightProgress?
}

extension PilotEdgeStatus: CustomStringConvertible {
    var description: String {
        return "Status... Position: \(self.position); Pilot: \(self.pilotInfo); Plan: \(self.flightPlan)"
    }
}

extension PilotEdgeStatus: JSONStringConvertible {
    var jsonString: String {
        let flightPlanString = self.flightPlan?.jsonString ?? "null"
        let flightProgressString = self.progress?.jsonString ?? "null"
        
        return "{\"position\":\(self.position.jsonString),\"pilot\":\(self.pilotInfo.jsonString),\"flightPlan\":\(flightPlanString), \"progress\":\(flightProgressString)}"
    }
}
