/*
 *	Retrieval Engine for PilotEdge Status
 */

import Foundation
import SWXMLHash

enum PilotEdgeRetrieverError: Error {
	case networkFailure // Issues downloading file
	case ioError // Issues writing to file
	case unknown
}

class PilotEdgeRetriever {
	// Singleton
	static let sharedRetriever = PilotEdgeRetriever()
	private init() {}
    
    private let fm = FileManager.default

	private let peUrl = "http://map.pilotedge.net/status_live.xml"
    
    var status: XMLIndexer?

	// Flags
    private let downloadInterval: UInt32 = 10 // Seconds
	private var networkFailureTicker = 0
	private var ioErrorTicker = 0
	private var stopRetrieving = false

	// Interface
	func start() throws {
		// Dispatch retrieval on background thread
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            try! self.retrieveStatus()
        }
	}

	func stop() { 	// Fails silenly
		self.stopRetrieving = true
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
		repeat {
            // Download file
            if let url = URL(string: self.peUrl) {
                HTTPInterface.get(url) {
                    data, error in
                    if data != nil {
                        self.status = SWXMLHash.parse(data!)
                    } else {
                        print(error!)
                    }
                }
            } else {
                throw PilotEdgeRetrieverError.unknown
            }
            
            if !self.stopRetrieving {
                sleep(self.downloadInterval)
            }
            
		} while !self.stopRetrieving
	}

}
