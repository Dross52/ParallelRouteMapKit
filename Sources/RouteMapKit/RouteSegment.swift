//
//  RouteSegment.swift
//  RouteMapKit
//
//  Created by Ross Dickerman on 3/16/25.
//


// Sources/RouteMapKit/RouteSegment.swift
// “MetraSegment.swift” refactored: now generic RouteSegment; each segment has coordinates and an ordered list of route IDs (affects offset rendering)
import Foundation
import CoreLocation

public struct RouteSegment {
    public let coordinates: [CLLocationCoordinate2D]
    public let routeIDs: [String] // Order determines offset in overlapping cases
    
    public init(coordinates: [CLLocationCoordinate2D], routeIDs: [String]) {
        self.coordinates = coordinates
        self.routeIDs = routeIDs
    }
}