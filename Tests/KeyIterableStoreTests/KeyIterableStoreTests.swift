import Foundation
import XCTest

import ValueStore
import IndexedStore
import KeyIterableStore

class KeyIterableStoreTests: XCTestCase {
	func testRef() async throws {
		let ref = Reference<[Int: String]>()
		try await ref.keyIterableStore().testCycle(7, value: "Hello")
	}

	func testOptionalSet() async throws {
		let ref = Reference<[Int: String]>()
		let store = ref.keyIterableStore()
		
		try await store.set(42, "Hello")
		let saved = try await store.load(42)
		
		XCTAssertEqual(saved, "Hello")
		
		try await store.set(42, nil)
		
		let loaded = try? await store.load(42)
		
		XCTAssertNil(loaded)
	}
}
