//
//  RoutePolyline.swift
//  RouteMapKit
//
//  Created by Ross Dickerman on 3/16/25.
//


// Sources/RouteMapKit/RoutePolyline.swift
// “MetraPolyline.swift” refactored: defines a route with unique id, name, color, segments & connection flags.
// Also provides combined coordinates and annotation coordinate calculation.
import Foundation
import CoreLocation
import MapKit

#if os(iOS)
import UIKit
public typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
public typealias PlatformColor = NSColor
#endif

public struct RoutePolyline {
    public let id: String
    public let name: String
    public let color: PlatformColor
    public let segments: [RouteSegment]
    public let connectStart: Bool
    public let connectEnd: Bool
    
    public init(id: String, name: String, color: PlatformColor, segments: [RouteSegment], connectStart: Bool = true, connectEnd: Bool = true) {
        self.id = id
        self.name = name
        self.color = color
        self.segments = segments
        self.connectStart = connectStart
        self.connectEnd = connectEnd
    }
    
    public func combinedCoordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        for segment in segments {
            coords.append(contentsOf: segment.coordinates)
        }
        return coords
    }
    
    public func annotationCoordinate() -> CLLocationCoordinate2D? {
        let coords = combinedCoordinates()
        guard !coords.isEmpty else { return nil }
        return coords[coords.count / 2]
    }
}

// In your RouteMapKit package
extension RoutePolyline {
    public var mkOverlay: MKPolyline {
        let coords = combinedCoordinates()
        return MKPolyline(coordinates: coords, count: coords.count)
    }
}

public extension RoutePolyline {
    var segmentPositions: [(ends: Int, position: Int, outOf: Int)] {
        var positions: [(ends: Int, position: Int, outOf: Int)] = []
        var cumulativeCount = 0
        for segment in segments {
            cumulativeCount += segment.coordinates.count
            // Use the RoutePolyline's id to find its index in the segment's routeIDs.
            let outOf = segment.routeIDs.count
            let position = segment.routeIDs.firstIndex(of: id) ?? 0
            positions.append((ends: cumulativeCount, position: position, outOf: outOf))
        }
        return positions
    }
}

public extension RoutePolyline {
    /// Returns annotation coordinates (and angles) along the route at given distance intervals.
    func annotationCoordinates(every distanceInterval: Double) -> [(coordinate: CLLocationCoordinate2D, angle: Double)] {
        let coords = combinedCoordinates()
        guard coords.count > 1, distanceInterval > 0 else { return [] }
        
        var annotations: [(coordinate: CLLocationCoordinate2D, angle: Double)] = []
        var lastAnnotationCoord = coords.first!
        
        for i in 1..<coords.count {
            let current = coords[i]
            let currentLoc = CLLocation(latitude: current.latitude, longitude: current.longitude)
            let lastLoc = CLLocation(latitude: lastAnnotationCoord.latitude, longitude: lastAnnotationCoord.longitude)
            let distance = currentLoc.distance(from: lastLoc)
            if distance >= distanceInterval {
                let angle = calculateAngle(from: lastAnnotationCoord, to: current)
                annotations.append((coordinate: current, angle: angle))
                lastAnnotationCoord = current
            }
        }
        return annotations
    }
    
    /// Helper to compute angle (in degrees) from one coordinate to the next.
    private func calculateAngle(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromPoint = MKMapPoint(from)
        let toPoint = MKMapPoint(to)
        let dx = toPoint.x - fromPoint.x
        let dy = toPoint.y - fromPoint.y
        let angleRadians = atan2(dy, dx)
        return angleRadians * 180 / .pi
    }
}
