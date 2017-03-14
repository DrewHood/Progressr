//
//  FlightProgress.swift
//  Progressr
//
//  Created by Drew Hood on 3/5/17.
//
//

import Foundation

struct FlightProgress {
    let timeRemaining: Int?
    let percentComplete: Float32
}

extension FlightProgress: CustomStringConvertible {
    var description: String {
        return ""
    }
}

extension FlightProgress: JSONStringConvertible {
    var jsonString: String {
        let timeString = self.timeRemaining != nil ? String(describing: self.timeRemaining) : "null"
        return "{\"percentComplete\":\(self.percentComplete),\"minutesRemaining\":\(timeString)}"
    }
}
