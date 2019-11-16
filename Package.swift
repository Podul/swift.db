// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "swift.db",
    targets: [
        .target(name: "swift.db", path: "Source")
    ],
    swiftLanguageVersions: [.v5]
)
