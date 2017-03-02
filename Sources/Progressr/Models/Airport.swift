//
//  Airport.swift
//  Progressr
//
//  Created by Drew Hood on 3/2/17.
//
//

import Foundation

struct Airport {
    let code: String
    let position: Coordinate2D
}

extension Airport: CustomStringConvertible {
    var description: String {
        return "Airport: \(self.code); Location: \(self.position)"
    }
}
