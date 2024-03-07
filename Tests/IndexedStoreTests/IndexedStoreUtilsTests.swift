import Foundation
import XCTest

import ValueStore
import IndexedStore

class IndexedStoreUtilsTests: XCTestCase {
	func testDefault() async throws {
		let key = "key"
		let store = Reference<[String: Int]>().indexedStore().default(42)
		
		let result = try await store.load(key)
		XCTAssertEqual(result, 42)
		
		let saved = try await store.save(key, 7)
		XCTAssertEqual(saved, 7)
		
		let savedAndLoaded = try await store.load(key)
		XCTAssertEqual(savedAndLoaded, 7)
		
		try await store.remove(key)
		
		let afterRemove = try await store.load(key)
		XCTAssertEqual(afterRemove, 42)
	}
	
	func testUpdate() async throws {
		let key = "key"
		let store = Reference<[String: Int]>([key: 7]).indexedStore()

		let updated = try await store.update(key) { value in
			value *= 2
		}
		
		XCTAssertEqual(updated, 14)
		
		let afterUpdate = try await store.load(key)
		XCTAssertEqual(afterUpdate, 14)
		
		let update2 = try await store.update(key, environment: ()) { value in
			value *= 2
		}
		
		XCTAssertEqual(update2, 28)
	}
	
	func testMap() async throws {
		let conversion = Conversion<Bool, Int>(
			to: { $0 ? 1 : 0 },
			from: { $0 == 0 ? false : true }
		)
		
		let key = "key"
		let store = Reference<[String: Int]>([key: 7]).indexedStore().map(conversion)
		
		let initial = try await store.load(key)
		XCTAssertEqual(initial, true)
		
		let saved = try await store.save(key, false)
		XCTAssertEqual(saved, false)
		
		try await store.remove(key)
	}
	
	func testMapError() async throws {
		enum TestError: Error {
			case expected
		}
		
		let key = "key"
		let store = IndexedStore<Void, String, Int>.error(ValueStoreError.noData).mapError { _ in
			TestError.expected
		}
		
		do {
			_ = try await store.load(key)
		} catch TestError.expected {
		} catch let error {
			XCTFail("Unexpected error: \(error)")
		}
		
		do {
			_ = try await store.save(key, 7)
		} catch TestError.expected {
		} catch let error {
			XCTFail("Unexpected error: \(error)")
		}
		
		do {
			_ = try await store.remove(key)
		} catch TestError.expected {
		} catch let error {
			XCTFail("Unexpected error: \(error)")
		}
	}
	
	func testLoadDefault() async throws {
		let key = "key"
		let store = Reference<[String: Int]>([key: 42]).indexedStore()
		
		let result = await store.load(key, default: 1)
		XCTAssertEqual(result, 42)
		
		try await store.remove(key)
		
		let afterRemove = await store.load(key, default: 1)
		XCTAssertEqual(afterRemove, 1)
	}
	
	func testLoadDefaultEnvironment() async throws {
		let key = "key"
		let store = Reference<[String: Int]>([key: 42]).indexedStore()
		
		let result = await store.load(key, default: 1, environment: ())
		XCTAssertEqual(result, 42)
		
		try await store.remove(key)
		
		let afterRemove = await store.load(key, default: 1, environment: ())
		XCTAssertEqual(afterRemove, 1)
	}
}
