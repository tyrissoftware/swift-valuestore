import Foundation
import XCTest
import ValueStore

class ValueStoreTests: XCTestCase {
	func testRef() async throws {
		let ref = Ref<Int?>()
		try await ref.valueStore.testCycle(7)
	}
	
	func testOptionalSet() async throws {
		let ref = Ref<Int?>()
		let store = ref.valueStore
		
		try await store.set(42)
		let saved = try await store.load()
		
		XCTAssertEqual(saved, 42)
		
		try await store.set(nil)
		
		let loaded = try? await store.load()
		
		XCTAssertNil(loaded)
	}
}
