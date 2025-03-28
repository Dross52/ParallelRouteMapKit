Here’s a clean and developer-friendly README.md you can use for your RouteMapKit package:

⸻

🗺️ RouteMapKit

A Swift package for advanced, customizable, and dynamic route rendering on MapKit.
RouteMapKit makes it easy to display multi-route polylines, intelligently offset overlapping segments, and add dynamic text annotations along the routes.

⸻

🚀 Features

✅ Dynamic route polylines with automatic offset for overlapping segments
✅ Zoom-scale adaptive line thickness
✅ Smooth annotation rendering using SwiftUI views on top of MapKit
✅ Supports both iOS and macOS platforms
✅ Easy to integrate with your existing MKMapView

⸻

🏗️ Architecture Overview

🔹 RoutePolyline

Represents an entire route, containing:
	•	id, name, color
	•	One or more RouteSegments
	•	Distance intervals for annotation placement
	•	Optional zoom threshold

🔹 RouteSegment

Represents a polyline segment of a route, with:
	•	Coordinates
	•	Optional name & color
	•	List of route IDs (used to offset overlapping segments)

🔹 RouteAnnotationViewModel

Holds data for text annotations:
	•	Coordinate, angle, zoom threshold
	•	Optional text & color override

🔹 RouteAnnotationView

A SwiftUI View to render an annotation’s text label at a specific angle with an optional stroke outline.

🔹 RoutePolylineRenderer

Custom MKPolylineRenderer that:
	•	Offsets overlapping segments based on route order
	•	Adjusts line thickness dynamically based on zoom
	•	Smoothly draws each route with rounded corners

⸻

🧩 How It Works
	•	Add RoutePolyline overlays to your MKMapView.
	•	Call RouteAnnotationViewModel.updateAnnotations() to add annotations.
	•	The renderer automatically draws overlapping routes with offset.
	•	The annotation view auto-rotates text to stay upright even when the map is rotated.

⸻

📄 Example Usage

import RouteMapKit

let mapView = MKMapView()

// Create your routes
let segments = [
    RouteSegment(coordinates: [...], routeIDs: ["Route1"], name: "Segment 1"),
    RouteSegment(coordinates: [...], routeIDs: ["Route1"])
]
let route = RoutePolyline(
    id: "Route1",
    name: "Route 1",
    color: .systemBlue,
    segments: segments,
    distanceInterval: 1000
)

// Add overlay
mapView.addOverlay(route.mkOverlay)

// Add annotations
await RouteAnnotationViewModel.updateAnnotations(
    on: mapView,
    using: [route],
    target: .segment
)



⸻

🎯 Annotation Targets

enum AnnotationTarget {
    case line      // Places annotations evenly along the entire polyline
    case segment   // Places annotations at each segment with optional names/colors
}



⸻

🌙 Dark Mode Support

Annotation text uses .oppositePrimary(colorScheme) to automatically select white or black stroke based on system appearance.

⸻

💻 Platform Support

Platform	Minimum Version
iOS	13.0+
macOS	10.15+



⸻

🔥 Future Improvements (Optional)
	•	Add tap handlers for annotations
	•	Animated annotation appearance
	•	Integration with MKClusterAnnotation
	•	Unit tests

⸻

📝 License

MIT License

⸻

If you want, I can also package this into an actual Package.swift with dependency instructions so it’s installable in one line.
Want me to?
