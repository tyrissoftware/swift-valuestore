import XCTest

import KeyIterableStore

extension KeyIterableStore where Value: Equatable {
	func testCycle(_ key: Key, value: Value, environment: Environment) async throws {
		let saved = try await self.save(key, value, environment)
		
		XCTAssert(self.allKeys().contains(key))
		
		let loaded = try await self.load(key, environment)
		
		XCTAssertEqual(saved, loaded)
		
		try await self.remove(key, environment)
		
		XCTAssertFalse(self.allKeys().contains(key))
		
		do {
			let loaded = try await self.load(key, environment)
			XCTFail("Value for key \(key) should be removed. \(loaded) found instead")
		} catch {
		}
	}
}

extension KeyIterableStore where Environment == Void, Value: Equatable {
	func testCycle(_ key: Key, value: Value) async throws {
		try await self.testCycle(key, value: value, environment: ())
	}
}
