//
//  RouteAnnotationView.swift
//  RouteMapKit
//
//  Created by Ross Dickerman on 3/16/25.
//


// Sources/RouteMapKit/RouteAnnotationView.swift
// “RouteAnnotationView.swift” refactored: A SwiftUI view for rendering route annotations.
// Default appearance provided; users can override via view modifiers.
import SwiftUI
import MapKit

public struct RouteAnnotationView: View {
    var text: String
    var textColor: Color
    var angle: Double // in degrees
    var size: CGFloat = 200
    
    @Environment(\.colorScheme) var colorScheme
    
    var adjustedAngle: Double {
        if angle > 90 {
            return angle - 180
        } else if angle < -90 {
            return angle + 180
        } else {
            return angle
        }
    }
    
    public var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(textColor)
            .stroke(color: .oppositePrimary(colorScheme), width: 1.0)
            .rotationEffect(Angle(degrees: adjustedAngle))
    }
}


struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue

    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }

    private func appliedStrokeBackground(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            return AnyView(
                content
                    .padding(strokeSize * 2)
                    .background(
                        Rectangle()
                            .foregroundColor(strokeColor)
                            .mask(alignment: .center) {
                                mask(content: content)
                            }
                    )
            )
        } else {
            return AnyView(content)
        }
    }

    func mask(content: Content) -> some View {
        Group {
            if #available(iOS 15.0, *) {
                Canvas { context, size in
                    context.addFilter(.alphaThreshold(min: 0.01))
                    if let resolvedView = context.resolveSymbol(id: id) {
                        context.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                    }
                } symbols: {
                    content
                        .tag(id)
                        .blur(radius: strokeSize)
                }
            } else {
                // Fallback: just return the blurred content without the Canvas mask.
                content
                    .tag(id)
                    .blur(radius: strokeSize)
            }
        }
    }
}

extension View {
    func stroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}

extension Color {
    static func oppositePrimary(_ colorScheme: ColorScheme) -> Color {
        return colorScheme != .dark ? .white : .black
    }
}

extension Color {
    static var background: Color {
        #if os(macOS)
        Color(.controlBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
}
