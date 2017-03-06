import PackageDescription

let package = Package(
    name: "SwiftScriptServer",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CORS.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/swift-script/swift-script.git", majorVersion: 0, minor: 0)
    ]
)
