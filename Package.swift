// swift-tools-version: 5.7

import PackageDescription

let package = Package(
	name: "swift-valuestore",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6),
	],
	products: [
		.library(
			name: "ValueStore",
			targets: ["ValueStore"]
		),
		.library(
			name: "IndexedStore",
			targets: ["IndexedStore"]
		),
		.library(
			name: "KeyIterableStore",
			targets: ["KeyIterableStore"]
		)
	],
	dependencies: [],
	targets: [
		.target(
			name: "ValueStore",
			dependencies: []
		),
		.testTarget(
			name: "ValueStoreTests",
			dependencies: ["ValueStore"]
		),
		.target(
			name: "IndexedStore",
			dependencies: [ "ValueStore" ]
		),
		.testTarget(
			name: "IndexedStoreTests",
			dependencies: ["IndexedStore"]
		),
		.target(
			name: "KeyIterableStore",
			dependencies: [ "ValueStore", "IndexedStore" ]
		),
		.testTarget(
			name: "KeyIterableStoreTests",
			dependencies: ["KeyIterableStore"]
		)
	]
)
