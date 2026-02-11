// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Infra",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Infra", targets: ["Infra"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
    ],
    targets: [
        .target(
            name: "Infra",
            dependencies: [
                "Domain",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ]
        ),
    ]
)
