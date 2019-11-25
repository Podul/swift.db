// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "swift.db",
    products: [
        .library(
            name: "SwiftDB",
            targets: ["SwiftDB"])
    ],
    targets: [
        .target(name: "SwiftDB")
        //.target(name: "SwiftDB", path: "Source")
    ],
    swiftLanguageVersions: [.v5]
)
