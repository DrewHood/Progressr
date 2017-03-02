//
//  AirportDatabase.swift
//  Progressr
//
//  Created by Drew Hood on 3/2/17.
//
//

import Foundation

enum AirportDatabaseError: Error {
    case nfdc(message: String?)
    case unknown
}

typealias AirportDictionary = [String: Airport]

class AirportDatabase {
    // Singleton
    static let sharedDatabase = AirportDatabase()
    private init() {}
    
    private let nfdcPath = "/Users/Drew/Documents/Code/Sandbox/CSVs/NfdcFacilities.csv"
    // TODO: Move this to a sustainable location
    
    private var airports: AirportDictionary = [:]
    
    subscript(code: String) -> Airport? {
        get {
            return self.airports[code]
        }
    }
    
    // Load Airports 
    func loadAirports() throws {
        // Get a streamer
        if let csvStream = StreamReader(path: self.nfdcPath) {
            print("Will begin loading airports!")
            
            let _ = csvStream.nextLine() // Ignore first line
            
            var str: String = ""
            repeat {
                str = csvStream.nextLine() ?? "F"
                
                if str != "F" {
                    let strComponents = str.components(separatedBy: ",")
                    let airportCode = strComponents[0].replacingOccurrences(of: "'", with: "")
                    let latStr = strComponents[1]
                    let lonStr = strComponents[2].replacingOccurrences(of: "\r", with: "") // Damn FAA puts carriage returns here #*&(&#$ bastards
                    
                    // Convert Lat/lon strings to usable coords
                    let lat = self.convertCoord(latStr)
                    let lon = self.convertCoord(lonStr)
                    
                    // Create Airport obj
                    let airport = Airport(code: airportCode, position: Coordinate2D(latitude: lat, longitude: lon))
                    self.airports[airportCode] = airport
                }
                
            } while str != "F"
            
            print("Loaded \(self.airports.count) airports!")
            
        } else {
            throw AirportDatabaseError.nfdc(message: "FATAL - Failed to open Nfdc DB.")
        }
    }
    
    /// Converts Nfdc coordinate strings to Decimal
    /// Nfdc format is "Deg-Min-Secs[N|S|E|W]
    private func convertCoord(_ coordStr: String) -> Double {
        // Determine positivity
        // Positive if N or E; negative if S or W
        let pos = coordStr.contains("N") || coordStr.contains("E")
        
        var cleanStr = coordStr
        cleanStr = cleanStr.replacingOccurrences(of: "N", with: "")
        cleanStr = cleanStr.replacingOccurrences(of: "E", with: "")
        cleanStr = cleanStr.replacingOccurrences(of: "S", with: "")
        cleanStr = cleanStr.replacingOccurrences(of: "W", with: "")
        
        // Extract components
        let components = cleanStr.characters.split{$0 == "-"}.map(String.init)
        
        let degrees = Double(components[0])!
        let minutes = Double(components[1])!
        let seconds = Double(components[2])!
        
        // Convert to decimal
        let coordDec = degrees + (minutes / 60) + (seconds / 3600)
        
        // Return
        return !pos ? Double(0 - coordDec) : coordDec
    }

}
