import Foundation
import XCTest

import ValueStore
import IndexedStore

class IndexedStoreKeyTests: XCTestCase {
	@MainActor
	func testTransform() async throws {
		let key1 = "key1"
		let key2 = "key2"
		
		let store = Reference<[String: Int]>(
			[
				key1: 1,
				key2: 2
			]
		).indexedStore()
		
		enum Keys: String {
			case key1
			case key2
		}
		
		let transformed = store.pullbackKey { (key: Keys) in
			key.rawValue
		}
		
		try await transformed.testCycle(.key1, value: 4)
		try await transformed.testCycle(.key2, value: 6)
	}
	
	@MainActor
	func testValueStore() async throws {
		let key1 = "key1"
		let key2 = "key2"
		
		let ref = Reference<[String: Int]>(
			[
				key1: 1,
				key2: 2
			]
		)
		
		let store = ref.indexedStore().valueStore(key: key1)
		
		try await store.testCycle(5)
		
		_ = try await store.save(6)
		
		XCTAssertEqual(ref.value?[key1], 6)
	}
	
	@MainActor
	func testSubscript() async throws {
		let key1 = "key1"
		let key2 = "key2"
		
		let ref = Reference<[String: Int]>(
			[
				key1: 1,
				key2: 2
			]
		)
		
		let store = ref.indexedStore()[key1]
		
		try await store.testCycle(5)
		
		_ = try await store.save(6)
		
		XCTAssertEqual(ref.value?[key1], 6)
	}
}
