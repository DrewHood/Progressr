/*
 *	Retrieval Engine for PilotEdge Status
 */

enum PilotEdgeRetrieverError {
	case networkFailure // Issues downloading file
	case ioError // Issues writing to file
	case unknown
}

class PilotEdgeRetriever {
	// Singleton
	static let sharedRetriever = PilotEdgeRetriever()
	private init() {}

	private let peUrl = "http://map.pilotedge.net/status_live.xml"
	static let statusPath = "tmp/pe_status.xml"

	// Flags
	private var networkFailureTicker = 0
	private var ioErrorTicker = 0
	private var stopRetrieving = false

	// Interface
	func start() throws {
		// Dispatch retrieval on background thread
	}

	func stop() { 	// Fails silenly
		self.stopRetrieving = true
	}

	func retrieveOnce() throws {
		// Dispatch to background with shouldContinue disabled
		// Succeeds silently
	}

	// Implementation
	private func retrieveStatus() throws {
		repeat {

		} while !self.stopRetrieving
	}

	private func writeStatusToFile() throws {

	}

}