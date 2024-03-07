import Foundation
import XCTest

import ValueStore
import IndexedStore
import KeyIterableStore

class KeyIterableStoreIterableTests: XCTestCase {
	func testClear() async throws {
		let ref = Reference<[String: Int]>([ "hello": 7, "world": 14 ])
		
		try await ref.keyIterableStore().clear(environment: ())
		
		XCTAssertEqual(ref.value, [:])
	}
	
	func testLoadValues() async throws {
		let ref = Reference<[String: Int]>([ "hello": 7, "world": 14 ])
		
		let values = try await ref.keyIterableStore().loadValues(environment: ())
		
		XCTAssertEqual(values, [7, 14])
	}
}
