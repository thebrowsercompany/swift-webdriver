public struct Location: Codable {
    public var latitude: Double
    public var longitude: Double
    public var altitude: Float

    init(latitude: Double, longitude: Double, altitude: Float) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
    
}

extension Location: Equatable {
    
}
