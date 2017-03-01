/*
 * Coordinate 2D
 */

struct Coordinate2D {
    let latitude: Double
    let longitude: Double
}

extension Coordinate2D: CustomStringConvertible {
    var description: String {
        return "(\(self.latitude), \(self.longitude))"
    }
}
