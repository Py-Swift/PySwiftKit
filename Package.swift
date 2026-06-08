// swift-tools-version: 6.0
import Foundation
import PackageDescription

let env = ProcessInfo.processInfo.environment

let local = true
let dev_mode = true

// When PIP_MODE=1 and cross-compiling for Android (SWIFT_ANDROID_HOME set),
// CPySwiftObject needs PIP_MODE defined so CPython.h skips the bundled
// PythonHeaders-android branch and uses the CPATH headers instead.
let pipMode   = env["PIP_MODE"] != nil
let isAndroid = env["SWIFT_ANDROID_HOME"] != nil

let CPython: Package.Dependency = if local {
    .package(path: "../CPython")
} else {
    .package(url: "https://github.com/py-swift/CPython", .upToNextMajor(from: .init(313, 8, 0)))
}

// PySwiftGenerators owns the macro plugin + swift-syntax.
//
// For production CI with zero swift-syntax compile time, replace with a .binaryTarget:
//
//   .binaryTarget(
//       name: "PySwiftGenerators",
//       url: "https://github.com/Py-Swift/PySwiftGenerators/releases/download/v0.0.1/PySwiftGenerators.artifactbundle.zip",
//       checksum: "<checksum from release workflow summary>"
//   )
//
// (then remove the PySwiftGenerators package dep from `dependencies` below)
let PySwiftGeneratorsDep: Package.Dependency = if local {
    .package(path: "../PySwiftGenerators")
} else {
    .package(url: "https://github.com/Py-Swift/PySwiftGenerators", from: "1.0.0")
}

var platforms: [SupportedPlatform] = [
    .iOS(.v13),
    .macOS(.v11)
]

let dependencies: [Package.Dependency] = [
    CPython,
    PySwiftGeneratorsDep,
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
]

func package_targets() -> [Target] {
    [
        .target(
            name: "CPySwiftObject",
            dependencies: [
                "CPython"
            ],
            path: "Sources/CPySwiftObject",
            publicHeadersPath: ".",
            cSettings: pipMode && isAndroid ? [.define("PIP_MODE")] : [],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "PySerializing",
            dependencies: [
                "CPython",
                "PySwiftKit",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "PySwiftKit",
            dependencies: [
                .product(name: "CPython", package: "CPython"),
                "CPySwiftObject",
                "PyProtocols"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "PySwiftConcurrency",
            dependencies: [
                .product(name: "CPython", package: "CPython"),
                "CPySwiftObject",
                "PyProtocols"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        // PyWrapping Related
        .target(
            name: "PyProtocols",
            dependencies: ["CPython"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "PySwiftWrapper",
            dependencies: [
                .product(name: "PySwiftGenerators", package: "PySwiftGenerators"),
                .product(name: "PyWrapperInfo", package: "PySwiftGenerators"),
                "CPython",
                "PySerializing",
                "PyProtocols"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
}

func get_targets() -> [Target] {
    var targets = package_targets()
    add_test_targets(&targets)
    return targets
}

func add_test_targets(_ targets: inout [Target]) {
    targets.append(.testTarget(
        name: "PyTests",
        dependencies: [
            "CPython",
            "PySwiftKit",
            "PySerializing",
            .product(name: "PyWrapperInternal", package: "PySwiftGenerators"),
            "PySwiftWrapper"
        ],
        resources: [
            .copy("python3.13"),
            .copy("pyswiftwrapper_tests.py")
        ],
        swiftSettings: [
            .swiftLanguageMode(.v5)
        ]
    ))
}

func get_products() -> [Product] {
    var products = [Product]()

    products.add_library("PySerializing")
    products.add_library("PySwiftWrapper")
    products.add_library("PySwiftKitBase", targets: [
        "PySwiftKit",
        "PySerializing",
        "PySwiftWrapper"
    ])
    products.add_library(
        "PySwiftKit",
        targets: [
            "PySwiftKit",
            "PySerializing",
            "PySwiftWrapper"
        ],
        type: .dynamic
    )

    return products
}


let package = Package(
    name: "PySwiftKit",
    platforms: platforms,
    products: get_products(),
    dependencies: dependencies,
    targets: get_targets()
)


extension Array where Element == Product {
    mutating func add_library(_ name: String, targets: [String], type: Product.Library.LibraryType? = nil) {
        append(.library(name: name, type: type, targets: targets))
    }
    mutating func add_library(_ name: String, target: String? = nil , type: Product.Library.LibraryType? = nil) {
        append(.library(name: name, type: type, targets: [target ?? name]))
    }
}

