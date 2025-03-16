//
//  RouteAnnotationVM.swift
//  RouteMapKit
//
//  Created by Ross Dickerman on 3/16/25.
//


// Sources/RouteMapKit/RouteAnnotationVM.swift
// “RouteAnnotationVM.swift” refactored: ViewModel for route annotations (e.g. every 10km along route – here simplified).
import Foundation
import MapKit
import SwiftUI

@available(macOS 10.15, *)
public class RouteAnnotationViewModel: NSObject, ObservableObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D
    public var angle: Double
    public var route: RoutePolyline

    // Add the title property so your view can pick it up.
    public var title: String? {
        return route.name
    }

    public init(route: RoutePolyline, coordinate: CLLocationCoordinate2D, angle: Double) {
        self.route = route
        self.coordinate = coordinate
        self.angle = angle
        super.init()
    }
}
