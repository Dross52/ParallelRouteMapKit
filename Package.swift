// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Package.swift – Declares the package and its iOS platform requirement.
import PackageDescription

let package = Package(
    name: "RouteMapKit",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "RouteMapKit", targets: ["RouteMapKit"])
    ],
    targets: [
        .target(name: "RouteMapKit", dependencies: [])
    ]
)
