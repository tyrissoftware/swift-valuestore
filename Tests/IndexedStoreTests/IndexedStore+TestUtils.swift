import XCTest

import IndexedStore

extension IndexedStore where Value: Equatable {
	func testCycle(_ key: Key, value: Value, environment: Environment) async throws {
		let saved = try await self.save(key, value, environment)
		let loaded = try await self.load(key, environment)
		
		XCTAssertEqual(saved, loaded)
		
		try await self.remove(key, environment)
		
		do {
			let loaded = try await self.load(key, environment)
			XCTFail("Value for key \(key) should be removed. \(loaded) found instead")
		} catch {
		}
	}
}

extension IndexedStore where Environment == Void, Value: Equatable {
	func testCycle(_ key: Key, value: Value) async throws {
		try await self.testCycle(key, value: value, environment: ())
	}
}
