// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "swift.db",
    products: [
        .library(
            name: "SwiftDB",
            targets: ["swift.db"])
    ],
    targets: [
        .target(name: "SwiftDB", path: "Source")
    ],
    swiftLanguageVersions: [.v5]
)
