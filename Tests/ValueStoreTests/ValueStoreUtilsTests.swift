import Foundation
import XCTest
import ValueStore

class ValueStoreUtilsTests: XCTestCase {
	func testDefault() async throws {
		let store = Ref<Int>().valueStore.default(42)
		
		let result = try await store.load()
		XCTAssertEqual(result, 42)
		
		let saved = try await store.save(7)
		XCTAssertEqual(saved, 7)
		
		let savedAndLoaded = try await store.load()
		XCTAssertEqual(savedAndLoaded, 7)
		
		try await store.remove()
		
		let afterRemove = try await store.load()
		XCTAssertEqual(afterRemove, 42)
	}
	
	func testUpdate() async throws {
		let store = Ref<Int>(7).valueStore

		let updated = try await store.update { value in
			value *= 2
		}
		
		XCTAssertEqual(updated, 14)
		
		let afterUpdate = try await store.load()
		XCTAssertEqual(afterUpdate, 14)
		
		let update2 = try await store.update(environment: ()) { value in
			value *= 2
		}
		
		XCTAssertEqual(update2, 28)
	}
	
	func testMap() async throws {
		let conversion = Conversion<Bool, Int>(
			to: { $0 ? 1 : 0 },
			from: { $0 == 0 ? false : true }
		)
		
		let store = Ref<Int>(7).valueStore.map(conversion)
		
		let initial = try await store.load()
		XCTAssertEqual(initial, true)
		
		let saved = try await store.save(false)
		XCTAssertEqual(saved, false)
		
		try await store.remove()
	}
	
	func testMapError() async throws {
		enum TestError: Error {
			case expected
		}
		
		let store = ValueStore<Void, Int>.error(ValueStoreError.noData).mapError { _ in
			TestError.expected
		}
		
		do {
			_ = try await store.load()
		}
		catch TestError.expected {
		}
		catch let error {
			XCTFail("Unexpected error: \(error)")
		}
		
		do {
			_ = try await store.save(7)
		}
		catch TestError.expected {
		}
		catch let error {
			XCTFail("Unexpected error: \(error)")
		}
		
		do {
			_ = try await store.remove()
		}
		catch TestError.expected {
		}
		catch let error {
			XCTFail("Unexpected error: \(error)")
		}
	}
}
