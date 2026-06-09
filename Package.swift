// swift-tools-version: 6.0
import Foundation
import PackageDescription

let env = ProcessInfo.processInfo.environment

let local = false
let dev_mode = true

// When PIP_MODE=1 and cross-compiling for Android (SWIFT_ANDROID_HOME set),
// CPySwiftObject needs PIP_MODE defined so CPython.h skips the bundled
// PythonHeaders-android branch and uses the CPATH headers instead.
let pipMode   = env["PIP_MODE"] == "1"
let isAndroid = env["SWIFT_ANDROID_HOME"] != nil

let CPython: Package.Dependency = if local {
    .package(path: "../CPython")
} else {
    .package(url: "https://github.com/py-swift/CPython", .upToNextMajor(from: .init(313, 8, 0)))
}

// PySwiftGenerators provides the macro plugin binary.
// PyWrapperInfo (pure-Swift runtime types used by PySwiftWrapper) is inlined
// into this package under Sources/PyWrapperInfo/.
//
// Binary lookup order (SPM 6.2 transitive local-path macro plugin workaround):
//  1. PYSWIFTGENERATORS_TOOL env var  — set automatically by pyswiftkit-builder / cibuildwheel
//  2. bin/ next to this Package.swift — run ./build-macro-binary.sh once after cloning
nonisolated(unsafe) let macroPluginFlags: [SwiftSetting] = {
    // unsafeFlags are forbidden in remote (versioned) dependencies.
    // PySwiftWrapper doesn't itself use macros — the plugin is only needed
    // by consuming targets (e.g. PyFilemanager). Skip when we're a remote dep.
    let pkgDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    if pkgDir.path.contains("/.build/checkouts/") { return [] }

    let fm = FileManager.default
    let candidates = [
        "PySwiftGenerators-tool-arm64-apple-macosx",
        "PySwiftGenerators-tool-x86_64-apple-macosx",
        "PySwiftGenerators-tool",
    ]
    func flags(_ path: String) -> [SwiftSetting] {
        [.unsafeFlags(["-load-plugin-executable", "\(path)#PySwiftGenerators"])]
    }
    if let tool = env["PYSWIFTGENERATORS_TOOL"], !tool.isEmpty { return flags(tool) }
    let binDir = pkgDir.appendingPathComponent("bin")
    for name in candidates {
        let path = binDir.appendingPathComponent(name).path
        if fm.isExecutableFile(atPath: path) { return flags(path) }
    }
    return []
}()

var platforms: [SupportedPlatform] = [
    .iOS(.v13),
    .macOS(.v11)
]

let dependencies: [Package.Dependency] = [
    CPython,
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
        // PyWrapperInfo: pure-Swift types used by PySwiftWrapper (inlined from PySwiftGenerators).
        .target(
            name: "PyWrapperInfo",
            dependencies: [],
            path: "Sources/PyWrapperInfo",
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
                "PyWrapperInfo",
                "CPython",
                "PySerializing",
                "PyProtocols",
            ],
            swiftSettings: macroPluginFlags + [
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

