import XCTest
import ValueStore

extension ValueStore where Value: Equatable {
	func testCycle(_ value: Value, environment: Environment) async throws {
		let saved = try await self.save(value, environment)
		let loaded = try await self.load(environment)
		
		XCTAssertEqual(saved, loaded)
		
		try await self.remove(environment)
		
		do {
			let loaded = try await self.load(environment)
			XCTFail("Value should be removed. \(loaded) found instead")
		}
		catch {
		}
	}
}

extension ValueStore where Environment == Void, Value: Equatable {
	func testCycle(_ value: Value) async throws {
		try await self.testCycle(value, environment: ())
	}
}
