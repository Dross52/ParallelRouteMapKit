//
//  RouteMapView.swift
//  RouteMapKit
//
//  Created by Ross Dickerman on 3/17/25.
//


// Sources/RouteMapKit/RouteMapView.swift
import SwiftUI
import MapKit

/// A SwiftUI view that wraps an MKMapView and displays RoutePolylines with custom annotations.
public struct RouteMapView: UIViewRepresentable {
    public let routePolylines: [RoutePolyline]
    public var annotationDistanceInterval: Double
    
    public init(routePolylines: [RoutePolyline], annotationDistanceInterval: Double = 1000) {
        self.routePolylines = routePolylines
        self.annotationDistanceInterval = annotationDistanceInterval
    }
    
    public func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Center around a default location (you can customize this as needed)
        mapView.setRegion(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ),
            animated: false
        )
        
        // Add overlays & track which overlay belongs to which route.
        for route in routePolylines {
            let overlay = route.mkOverlay
            context.coordinator.overlayMapping[ObjectIdentifier(overlay)] = route
            mapView.addOverlay(overlay)
        }
        
        // Add route annotations (labels)
        context.coordinator.updateRouteAnnotations(on: mapView)
        
        return mapView
    }
    
    public func updateUIView(_ uiView: MKMapView, context: Context) {
        // Refresh annotations if routes or zoom level changes.
        context.coordinator.updateRouteAnnotations(on: uiView)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(routePolylines: routePolylines, annotationDistanceInterval: annotationDistanceInterval)
    }
    
    // MARK: - Coordinator
    
    public class Coordinator: NSObject, MKMapViewDelegate {
        /// Mapping from overlay identifiers to RoutePolyline.
        public var overlayMapping: [ObjectIdentifier: RoutePolyline] = [:]
        public var routePolylines: [RoutePolyline]
        public var annotationDistanceInterval: Double
        
        public init(routePolylines: [RoutePolyline], annotationDistanceInterval: Double) {
            self.routePolylines = routePolylines
            self.annotationDistanceInterval = annotationDistanceInterval
        }
        
        public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline,
               let route = overlayMapping[ObjectIdentifier(overlay)] {
                return RoutePolylineRenderer(overlay: polyline,
                                             routePolyline: route,
                                             segmentPositions: route.segmentPositions)
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is RouteAnnotationViewModel {
                let identifier = "RouteAnnotationView"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? RouteAnnotationViewWrapper
                if annotationView == nil {
                    annotationView = RouteAnnotationViewWrapper(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = false
                } else {
                    annotationView?.annotation = annotation
                }
                annotationView?.zPriority = .min
                rotateRouteNames(on: mapView)
                return annotationView
            }
            return nil
        }
        
        public func updateRouteAnnotations(on mapView: MKMapView) {
            // Remove existing route annotations (our custom ones)
            let existingAnnotations = mapView.annotations.filter { $0 is RouteAnnotationViewModel }
            mapView.removeAnnotations(existingAnnotations)
            
            // For each route, add annotations along the route.
            var newAnnotations: [RouteAnnotationViewModel] = []
            for route in routePolylines {
                let annotationCoords = route.annotationCoordinates(every: annotationDistanceInterval)
                for (coordinate, angle) in annotationCoords {
                    let annotation = RouteAnnotationViewModel(route: route, coordinate: coordinate, angle: angle)
                    newAnnotations.append(annotation)
                }
            }
            
            mapView.addAnnotations(newAnnotations)
            rotateRouteNames(on: mapView)
        }
        
        public func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            rotateRouteNames(on: mapView)
        }
        
        public func rotateRouteNames(on mapView: MKMapView) {
            #if os(iOS)
            for annotation in mapView.annotations {
                if let annotationView = mapView.view(for: annotation) as? RouteAnnotationViewWrapper {
                    annotationView.updateRotation()
                }
            }
            #endif
        }
    }
}
