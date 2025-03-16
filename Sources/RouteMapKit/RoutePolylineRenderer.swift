//
//  CustomPolylineRenderer.swift
//  RouteMapKit
//
//  Created by Ross Dickerman on 3/16/25.
//


// Sources/RouteMapKit/RoutePolylineRenderer.swift
import MapKit

public class RoutePolylineRenderer: MKPolylineRenderer {
    public var routePolyline: RoutePolyline
    // Each tuple: (ends: index of segment end, position: current route’s order, outOf: total overlapping routes)
    public var segmentPositions: [(ends: Int, position: Int, outOf: Int)] = []
    
    public init(overlay: MKOverlay, routePolyline: RoutePolyline, segmentPositions: [(ends: Int, position: Int, outOf: Int)] = []) {
        self.routePolyline = routePolyline
        self.segmentPositions = segmentPositions
        super.init(overlay: overlay)
    }
    
    public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let polyline = overlay as? MKPolyline else { return }
        let points = polyline.points()
        let pointCount = polyline.pointCount
        
        // Dynamic line width calculation
        let lineWidth = 5 / pow(zoomScale, 0.75)
        let baseOffset: CGFloat = lineWidth * 1.5
        
        let path = CGMutablePath()
        
        // Draw normally if no segment positions provided
        if segmentPositions.isEmpty {
            if pointCount > 0 {
                path.move(to: self.point(for: points[0]))
                for i in 1..<pointCount {
                    path.addLine(to: self.point(for: points[i]))
                }
            }
        } else {
            var pointCounter = 0
            // Iterate through each segment defined in segmentPositions
            for segment in segmentPositions {
                let endOfSegment = segment.ends
                let preset = baseOffset * CGFloat(segment.outOf) / 2.0
                let offsetValue = baseOffset * CGFloat(segment.position) - preset
                
                for i in pointCounter..<endOfSegment {
                    if i == 0 {
                        // First point in this segment
                        let currentPoint = self.point(for: points[i])
                        let nextPoint = self.point(for: points[i + 1])
                        let angle = angleRelativeToEastWest(pointA: currentPoint, pointB: nextPoint)
                        path.move(to: offsetPoint(from: currentPoint, by: angle, to: offsetValue))
                    } else if i == pointCount - 1 {
                        // Last point in the polyline
                        let lastPoint = self.point(for: points[i])
                        let prevPoint = self.point(for: points[i - 1])
                        let angle = angleRelativeToEastWest(pointA: prevPoint, pointB: lastPoint)
                        path.addLine(to: offsetPoint(from: lastPoint, by: angle, to: offsetValue))
                    } else {
                        // Intermediate points: blend the offset between segments
                        let lastPoint = self.point(for: points[i - 1])
                        let currentPoint = self.point(for: points[i])
                        let nextPoint = self.point(for: points[i + 1])
                        let angleToNext = angleRelativeToEastWest(pointA: currentPoint, pointB: nextPoint)
                        let angleFromLast = angleRelativeToEastWest(pointA: lastPoint, pointB: currentPoint)
                        let c = CGFloat.pi - angleToNext + angleFromLast
                        let d = c / 2.0
                        let computedOffset = offsetValue / sin(d)
                        let adjustedPoint = findOffSetPoint(from: currentPoint, at: d + angleToNext, to: computedOffset)
                        path.addLine(to: adjustedPoint)
                    }
                    pointCounter += 1
                }
            }
        }
        
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.addPath(path)
        context.setStrokeColor(routePolyline.color.cgColor)
        context.setLineWidth(lineWidth)
        context.strokePath()
    }
    
    // Returns a point offset by a given angle and distance.
    func offsetPoint(from point: CGPoint, by angle: CGFloat, to offset: CGFloat) -> CGPoint {
        CGPoint(x: point.x - offset * sin(angle),
                y: point.y - offset * cos(angle))
    }
    
    // Computes an offset point given an angle and distance.
    func findOffSetPoint(from point: CGPoint, at angle: CGFloat, to length: CGFloat) -> CGPoint {
        CGPoint(x: point.x + length * cos(angle),
                y: point.y - length * sin(angle))
    }
    
    // Calculates the angle (in radians) relative to the East-West axis.
    func angleRelativeToEastWest(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        let direction = CGPoint(x: pointB.x - pointA.x, y: pointB.y - pointA.y)
        var angleRadians = atan2(direction.y, direction.x)
        angleRadians *= -1
        return angleRadians
    }
}
