# RouteMapKit

RouteMapKit is a Swift Package that provides a customizable `MKMapView` wrapper for displaying polylines with route labels. It allows for multiple overlapping routes, automatic annotation placement, and dynamic label rotation.

## Features

✅ **Custom Polyline Rendering** – Supports multiple overlapping routes with segment-specific offsets.  
✅ **Route Annotations** – Labels automatically placed along the route at intervals.  
✅ **Real-Time Rotation** – Labels adjust when the map rotates.  
✅ **SwiftUI Integration** – Use it easily within a SwiftUI project.  

## Installation

### Using Swift Package Manager (SPM)
1. Open your Xcode project.  
2. Go to **File > Add Packages…**  
3. Enter the repository URL:
4. Select **Add Package** and link it to your target.

## Usage

### Basic Example
```swift
import SwiftUI
import RouteMapKit

struct ContentView: View {
 var body: some View {
     let redRoute = RoutePolyline(
         id: "red",
         name: "Red Route",
         color: .red,
         segments: [/* red segments here */]
     )
     
     let blueRoute = RoutePolyline(
         id: "blue",
         name: "Blue Route",
         color: .blue,
         segments: [/* blue segments here */]
     )
     
     RouteMapView(routePolylines: [redRoute, blueRoute], annotationDistanceInterval: 500)
         .edgesIgnoringSafeArea(.all)
 }
}

#Preview {
 ContentView()
}
