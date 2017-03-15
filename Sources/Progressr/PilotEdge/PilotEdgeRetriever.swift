/*
 *	Retrieval Engine for PilotEdge Status
 */

import Foundation
import PerfectXML
import PerfectLogger
import Dispatch

enum PilotEdgeRetrieverError: Error {
    case networkFailure // Issues downloading file
    case unknown
}

class PilotEdgeRetriever {
    // Singleton
    static let sharedRetriever = PilotEdgeRetriever()
    private init() {}
    
    private let fm = FileManager.default
    
    private let peUrl = "http://map.pilotedge.net/status_live.xml"
    
    var status: XDocument?
    
    // Flags
    private var downloadInterval: UInt32 {
        guard let interval = CONFIGURATION["pe:downloadInterval"] as? String else { return 10 }
        
        return UInt32(interval)!
    }
    private var networkFailureTicker = 0
    private var stopRetrieving = false
    private var pilotEdgeTestMode: Bool {
        return CONFIGURATION["pe:debug"] != nil
    }
    private var networkAttempts: Int {
        guard let attempts = CONFIGURATION["pe:downloadAttempts"] as? String else { return 3 }
        
        return Int(attempts)!
    }
    
    // Interface
    func start() throws {
        LogFile.info("Starting PE status retrieval every \(self.downloadInterval) seconds")
        
        // Dispatch retrieval on background thread
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            try! self.retrieveStatus()
        }
    }
    
    func stop() { 	// Fails silenly
        self.stopRetrieving = true
        LogFile.info("Disabling PE status retrieval.")
    }
    
    func retrieveOnce() throws {
        // Dispatch to background with shouldContinue disabled
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            self.stopRetrieving = true
            try! self.retrieveStatus()
        }
    }
    
    // Implementation
    private func retrieveStatus() throws {
        // See if we're in debug mode
        if self.pilotEdgeTestMode {
            // Open the test file.
            guard let testXmlPath = CONFIGURATION["pe:testpath"] as? String else { throw PilotEdgeInterfaceError.retrievalError }
            if let testXmlData = self.fm.contents(atPath: testXmlPath) {
                let xml = String(data: testXmlData, encoding: .ascii)
                self.status = XDocument(fromSource: xml!)
            }
            
            return
        }
        
        repeat {
            // Throw if we need to
            // This is a workaround for not being able to throw in closures
            if self.networkFailureTicker == self.networkAttempts {
                LogFile.critical("PilotEdge status retrieval failed \(self.networkFailureTicker) times. Throwing!")
                
                self.stopRetrieving = true
                throw PilotEdgeRetrieverError.networkFailure
            }
            
            // Download file
            if let url = URL(string: self.peUrl) {
                HTTPInterface.get(url) {
                    data, error in
                    if data != nil {
                        // If successful, reset the failure ticker
                        self.networkFailureTicker = 0
                        
                        // stringify
                        // TODO: Handle error
                        let dataStr = String(data: data!, encoding: .ascii)
                        self.status = XDocument(fromSource: dataStr!)
                    } else {
                        LogFile.error("Error retrieving PE status: \(error)")
                        self.networkFailureTicker += 1
                    }
                }
            } else {
                LogFile.error("Couldn't create URL to PE Status!")
            }
            
            if !self.stopRetrieving {
                sleep(self.downloadInterval)
            }
            
        } while !self.stopRetrieving
    }
    
}
