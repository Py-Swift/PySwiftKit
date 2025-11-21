// swift-tools-version: 6.0
import Foundation
import PackageDescription
import CompilerPluginSupport




let env = ProcessInfo.processInfo.environment

let local = false
let dev_mode = true

let CPython: Package.Dependency = if local {
    .package(path: "../CPython")
} else {
    .package(url: "https://github.com/py-swift/CPython", .upToNextMajor(from: .init(313, 8, 0)))
}


var platforms: [SupportedPlatform] = [
    .iOS(.v13),
    .macOS(.v11)
]


let dependencies: [Package.Dependency] = [
    CPython,
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
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
            name: "PyWrapperInfo",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "PySwiftWrapper",
            dependencies: [
                "PySwiftGenerators",
                "CPython",
                "PyWrapperInfo",
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
    
    add_macro_targets(&targets)
    add_test_targets(&targets)
    
    return targets
}

func add_macro_targets(_ targets: inout [Target]) {
    targets.append(
        .target(
            name: "PyWrapperInternal",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "PyWrapperInfo"
            ]
        ),
    )
    targets.append(
        .macro(
            name: "PySwiftGenerators",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "PyWrapperInternal",
                "PyWrapperInfo"
            ]
        ),
    )
}

func add_test_targets(_ targets: inout [Target]) {
    targets.append(.testTarget(
        name: "PyTests",
        dependencies: [
            "CPython",
            "PySwiftKit",
            "PySerializing",
            "PyWrapperInternal",
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
    products.add_library("PySwiftKit")
    products.add_library("PySwiftWrapper")
    products.add_library("PySwiftKitBase", targets: [
        "PySwiftKit",
        "PySerializing",
        "PySwiftWrapper"
    ])
    
    if dev_mode {
        //products.add_library("PyWrapperInternal")
        //products.add_library("PySwiftGenerators")
    }
    
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
