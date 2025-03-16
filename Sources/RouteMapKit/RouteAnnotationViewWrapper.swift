//
//  RouteAnnotationViewWrapper.swift
//  RouteMapKit
//
//  Created by Ross Dickerman on 3/17/25.
//


// Sources/RouteMapKit/RouteAnnotationViewWrapper.swift
import SwiftUI
import MapKit

public class RouteAnnotationViewWrapper: MKAnnotationView {
    
    private var hostingController: UIHostingController<RouteAnnotationView>?
    
    public override var annotation: MKAnnotation? {
        didSet {
            guard let annotation = annotation as? RouteAnnotationViewModel  else { return }
            setupSwiftUIView(for: annotation)
        }
    }

    private func setupSwiftUIView(for annotation: RouteAnnotationViewModel) {
        let routeView = RouteAnnotationView(
            text: annotation.title ?? "",
            textColor: Color(annotation.route.color),
            angle: annotation.angle ?? 0
        )
        
        if let hc = hostingController {
            hc.rootView = routeView
        } else {
            let hc = UIHostingController(rootView: routeView)
            hc.view.backgroundColor = .clear
            hostingController = hc
            addSubview(hc.view)
        }
        
        hostingController?.view.frame = bounds
        frame = CGRect(x: 0, y: 0, width: routeView.size, height: routeView.size)
        clipsToBounds = false
    }
    
    /// Rotates the annotation view so text isn't turned with the map.
    public func updateRotation(using mapView: MKMapView? = nil) {
        let map = mapView ?? findMapView()
        guard let map = map else {
            return
        }
        // Negate the map's heading
        transform = CGAffineTransform(rotationAngle: -CGFloat(map.camera.heading) * (.pi / 180))
    }
    
    private func findMapView() -> MKMapView? {
        var superV = superview
        while let view = superV {
            if let mapView = view as? MKMapView {
                return mapView
            }
            superV = view.superview
        }
        return nil
    }
}
