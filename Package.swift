// swift-tools-version:5.9

import PackageDescription
import CompilerPluginSupport

let kivy = false
let local = false

let pykit: Package.Dependency = if local {
    .package(path: "/Volumes/CodeSSD/PythonSwiftGithub/PyKit")
} else {
    .package(path: "/Volumes/CodeSSD/PythonSwiftGithub/PyKit")
}

let pythoncore: Package.Dependency = if kivy {
    .package(url: "https://github.com/KivySwiftLink/PythonCore", .upToNextMajor(from: .init(311, 0, 0)))
} else {
    .package(url: "https://github.com/PythonSwiftLink/PythonCore", .upToNextMajor(from: .init(311, 0, 0)))
}

let package = Package(
	name: "PySwiftKit",
	platforms: [.macOS(.v11), .iOS(.v13)],
	products: [
		.library(
			name: "PySwiftKit",
			targets: ["PySwiftKit"]
		),
		.library(
			name: "PySwiftObject",
			targets: ["PySwiftObject"]
		),
		.library(
			name: "PyCollection",
			targets: ["PyCollection"]
		),
		.library(
			name: "PyUnpack",
			targets: ["PyUnpack"]
		),
        .library(
            name: "PyUnwrap",
            targets: ["PyUnwrap"]
        ),
        .library(
            name: "PyWrap",
            targets: ["PyWrap"]
        ),
		.library(
			name: "PyExecute",
			targets: ["PyExecute"]
		),
		.library(
			name: "PyCallable",
			targets: ["PyCallable"]
		),
		.library(
			name: "PyMemoryView",
			targets: ["PyMemoryView"]
		),
		.library(
			name: "PyDictionary",
			targets: ["PyDictionary"]
		),
		.library(
			name: "PyUnicode",
			targets: ["PyUnicode"]
		),
		.library(
			name: "PyExpressible",
			targets: ["PyExpressible"]
		),
		.library(
			name: "PyComparable",
			targets: ["PyComparable"]
		),
//		.library(
//			name: "PyEncode",
//			targets: ["PyEncode"]
//		),
        .library(
            name: "PySerializing",
            targets: ["PySerializing"]
        ),
//        .library(
//            name: //"PyDeserializing",
//            targets: [//"PyDeserializing"]
//        ),
        .library(
            name: "PyBuffering",
            targets: ["PyBuffering"]
        ),
//		.library(
//			name: "PyDecode",
//			targets: ["PyDecode"]
//		),
		.library(
			name: "PyTypes",
			targets: ["PyTypes"]
		),
		.library(
			name: "PyTuples",
			targets: ["PyTuples"]
		),
		.library(
			name: "SwiftonizeModules",
			targets: [
				"PySwiftKit",
				"PySwiftObject",
				"PyUnpack",
				//"PyEncode",
                "PySerializing",
				"PyCallable",
				"PyDictionary",
				"PyTuples"
			]
		),
	],
	dependencies: [

		//.package(url: "https://github.com/PythonSwiftLink/PythonCore", .upToNextMajor(from: .init(311, 0, 0))),
        pythoncore,
        //pykit,
		.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
        .package(url: "https://github.com/PythonSwiftLink/SwiftonizePlugin", .upToNextMajor(from: "0.0.0")),
	],
	
	targets: [
		.target(
			name: "PyExecute",
			dependencies: [
				"PySwiftKit",
			]
		),
		.target(
			name: "PyCallable",
			dependencies: [
				"PySwiftKit",
                "PySwiftObject",
                "PySerializing",
			]
		),
		.target(
			name: "PyUnpack",
			dependencies: [
				"PySwiftKit",
				"PyCollection",
                "PySerializing",
			]
		),
        .target(
            name: "PyUnwrap",
            dependencies: [
                "PySwiftKit",
                "PyCollection",
                "PyTypes"
            ]
        ),
        .target(
            name: "PyWrap",
            dependencies: [
                "PySwiftKit",
                "PyCollection",
                "PyTypes"
            ]
        ),
		.target(
			name: "PyExpressible",
			dependencies: [
				"PySwiftKit",
			]
		),
		.target(
			name: "PyCollection",
			dependencies: [
				"PySwiftKit",
                "PySerializing",
			]
		),
		.target(
			name: "PyMemoryView",
			dependencies: [
				"PySwiftKit",
                "PySerializing",
			]
		),
		.target(
			name: "PyUnicode",
			dependencies: [
				"PySwiftKit",
			]
		),
		.target(
			name: "PyDictionary",
			dependencies: [
				"PySwiftKit",
                "PySerializing"
			]
		),
		.target(
			name: "PyComparable",
			dependencies: [
				"PySwiftKit",
				"PyTypes",
			]
		),
        .target(
            name: "PySerializing",
            dependencies: [
                "PySwiftKit",
                "PyTypes",
                "PyComparable",
                //"PyKit"
            ]
        ),
        .target(
            name: "PyBuffering",
            dependencies: [
                "PySwiftKit",
                "PyTypes",
                "PyComparable"
            ]
        ),
		.target(
			name: "PyTypes",
			dependencies: [
                "PySwiftObject",
				"PySwiftKit",
			]
		),
		.target(
			name: "PyTuples",
			dependencies: [
                "PySerializing",
				"PySwiftKit",
			]
		),
		
            .target(
                name: "PyObjc",
                dependencies: [
                    "PySerializing",
                    "PySwiftKit",
                ]
            ),
		
		.target(
			name: "PySwiftObject",
			dependencies: [
				"PythonCore",
				"PySwiftKit",
			],
			resources: [
				
			],
			swiftSettings: []
		),
		.target(
			name: "PySwiftKit",
			dependencies: [
				"PythonCore",
				"_PySwiftObject"
				//"PythonTypeAlias"
			],
			resources: [
				
			],
			swiftSettings: [],
			linkerSettings: [
				.linkedLibrary("bz2"),
				.linkedLibrary("z"),
				.linkedLibrary("ncurses"),
				.linkedLibrary("sqlite3"), 
			]
		),
        .target(
            name: "_PySwiftObject",
            dependencies: [
                "PythonCore"
            ]
        ),
		.testTarget(
			name: "PythonSwiftCoreTests",
			dependencies: [
				"PythonCore",
				"PySwiftKit",
                "PySwiftObject",
				"PyExecute",
				"PyCollection",
				"PyDictionary",
                "PyUnwrap",
                "PyUnpack",
                "PyWrap",
                //"PyDeserializing",
                "PyCallable",
				
			],
			resources: [
				.copy("python_stdlib"),
			],
            plugins: [
               // .plugin(name: "Swiftonize", package: "SwiftonizePlugin")
            ]
		),
		//			.target(
		//				name: "Python",
		//				dependencies: ["Python"],
		//				path: "Sources/Python",
		//				linkerSettings: [
		//					.linkedLibrary("ncurses"),
		//					.linkedLibrary("sqlite3"),
		//					.linkedLibrary("z"),
		//				]
		//			),
		//			.target(
		//				name: "PythonTypeAlias",
		//				dependencies: [
		//					"Python",
		//				]
		//			),
		
		//		.binaryTarget(name: "Python", path: "Sources/Python/Python.xcframework"),
			//.binaryTarget(name: "Python", url: "https://github.com/PythonSwiftLink/PythonCore/releases/download/311.0.2/Python.zip", checksum: "410d57419f0ccbc563ab821e3aa241a4ed8684888775f4bdea0dfc70820b9de6")
	]
)
