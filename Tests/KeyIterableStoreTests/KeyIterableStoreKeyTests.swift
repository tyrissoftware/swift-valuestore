import Foundation
import XCTest

import ValueStore
import IndexedStore
import KeyIterableStore

class KeyIterableStoreKeyTests: XCTestCase {
	@MainActor
	func testKeys() async throws {
		let key1 = "key1"
		let key2 = "key2"
		
		let store = Reference<[String: Int]>(
			[
				key1: 1,
				key2: 2
			]
		).keyIterableStore()
		
		var allValues = try await store.loadValues()
		
		XCTAssertEqual(allValues, [1, 2])
		
		try await store.clear()
		
		allValues = try await store.loadValues()
		
		XCTAssertEqual(allValues, [])
	}
	
	@MainActor
	func testTransform() async throws {
		let key1 = "key1"
		let key2 = "key2"
		
		let store = Reference<[String: Int]>(
			[
				key1: 1,
				key2: 2
			]
		).keyIterableStore()
		
		enum Keys: String {
			case key1
			case key2
		}
		
		let transformed = store.transformKey { key in
			key.rawValue
		} from: { raw in
			Keys(rawValue: raw) ?? .key1
		}

		
		try await transformed.testCycle(.key1, value: 4)
		try await transformed.testCycle(.key2, value: 6)
	}
}
