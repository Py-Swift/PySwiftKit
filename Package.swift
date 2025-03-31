// swift-tools-version:5.9

import PackageDescription

let package = Package(
	name: "PySwiftKit",
	platforms: [.macOS(.v11), .iOS(.v13)],
	products: [
		.library(
			name: "PySwiftCore",
			targets: ["PySwiftCore"]
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
        .library(
            name: "PyDeserializing",
            targets: ["PyDeserializing"]
        ),
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
				"PySwiftCore",
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

		.package(url: "https://github.com/PythonSwiftLink/PythonCore", .upToNextMajor(from: .init(311, 0, 0))),
		.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
        .package(url: "https://github.com/PythonSwiftLink/SwiftonizePlugin", .upToNextMajor(from: "0.0.0")),

	],
	
	targets: [
		.target(
			name: "PyExecute",
			dependencies: [
				"PySwiftCore",
				//"PyDecode",
				//"PyEncode"
			]
		),
		.target(
			name: "PyCallable",
			dependencies: [
				"PySwiftCore",
                "PySwiftObject",
//				"PyDecode",
//				"PyEncode"
                "PySerializing",
                "PyDeserializing"
			]
		),
		.target(
			name: "PyUnpack",
			dependencies: [
				"PySwiftCore",
				"PyCollection",
                //"PyDecode",
                //"PyEncode"
                "PySerializing",
                "PyDeserializing"
			]
		),
        .target(
            name: "PyUnwrap",
            dependencies: [
                "PySwiftCore",
                "PyCollection",
                "PyTypes"
            ]
        ),
        .target(
            name: "PyWrap",
            dependencies: [
                "PySwiftCore",
                "PyCollection",
                "PyTypes"
            ]
        ),
		.target(
			name: "PyExpressible",
			dependencies: [
				"PySwiftCore",
//				"PyDecode",
//				"PyEncode"
			]
		),
		.target(
			name: "PyCollection",
			dependencies: [
				"PySwiftCore",
                //"PyDecode",
                //"PyEncode"
                "PySerializing",
                "PyDeserializing"
			]
		),
		.target(
			name: "PyMemoryView",
			dependencies: [
				"PySwiftCore",
                //"PyDecode",
                //"PyEncode"
                "PySerializing",
                //"PyDeserializing"
			]
		),
		.target(
			name: "PyUnicode",
			dependencies: [
				"PySwiftCore",
                //"PyDecode",
                //"PyEncode"
                //"PySerializing",
                "PyDeserializing"
			]
		),
		.target(
			name: "PyDictionary",
			dependencies: [
				"PySwiftCore",
                //"PyDecode",
                //"PyEncode"
                "PySerializing",
                "PyDeserializing"
			]
		),
		.target(
			name: "PyComparable",
			dependencies: [
				"PySwiftCore",
				"PyTypes",
				//				"PyEncode"
			]
		),
//		.target(
//			name: "PyDecode",
//			dependencies: [
//				"PySwiftCore",
//				"PyTypes",
//				"PyComparable"
//			]
//		),
//		.target(
//			name: "PyEncode",
//			dependencies: [
//				"PySwiftCore",
//			]
//		),
        .target(
            name: "PySerializing",
            dependencies: [
                "PySwiftCore",
            ]
        ),
        .target(
            name: "PyDeserializing",
            dependencies: [
                "PySwiftCore",
                "PyTypes",
                "PyComparable"
            ]
        ),
        .target(
            name: "PyBuffering",
            dependencies: [
                "PySwiftCore",
                "PyTypes",
                "PyComparable"
            ]
        ),
		.target(
			name: "PyTypes",
			dependencies: [
				//"PyEncode",
                //"PyDeserializing",
                "PySwiftObject",
				"PySwiftCore",
			]
		),
		.target(
			name: "PyTuples",
			dependencies: [
                //"PyDecode",
                //"PyEncode"
                "PySerializing",
                "PyDeserializing",
				"PySwiftCore",
			]
		),
		
            .target(
                name: "PyObjc",
                dependencies: [
                    //"PyDecode",
                    //"PyEncode"
                    "PySerializing",
                    "PyDeserializing",
                    "PySwiftCore",
                ]
            ),
		
		.target(
			name: "PySwiftObject",
			dependencies: [
				"PythonCore",
				"PySwiftCore",
				//"_PySwiftObject"
				//"PythonTypeAlias"
			],
			resources: [
				
			],
			swiftSettings: []
		),
		.target(
			name: "PySwiftCore",
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
				"PySwiftCore",
                "PySwiftObject",
				"PyExecute",
				"PyCollection",
				"PyDictionary",
                "PyUnwrap",
                "PyUnpack",
                "PyWrap",
                "PyDeserializing",
                "PyCallable"
				
			],
			resources: [
				.copy("python_stdlib"),
			],
            plugins: [
                .plugin(name: "Swiftonize", package: "SwiftonizePlugin")
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
