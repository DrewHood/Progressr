import PackageDescription

let package = Package(
    name: "Progressr",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-XML.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/Configuration.git", majorVersion: 0, minor: 2)
    ]
)
