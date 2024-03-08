import Foundation
import XCTest

import ValueStore
import IndexedStore
import KeyIterableStore

class KeyIterableStoreCreationTests: XCTestCase {
	func testConst() async throws {
		let key = "key"
		let store = KeyIterableStore<Void, String, Int>.const(42)
		
		let loaded = try await store.load(key)
		XCTAssertEqual(loaded, 42)
		
		let saved = try await store.save(key, 42)
		XCTAssertEqual(saved, 42)
		
		let loadedAfterSave = try await store.load(key)
		XCTAssertEqual(loadedAfterSave, 42)

		try await store.remove(key)
		
		let loadedAfterRemove = try await store.load(key)
		XCTAssertEqual(loadedAfterRemove, 42)
		
		let loadedOtherKey = try await store.load("world")
		XCTAssertEqual(loadedOtherKey, 42)
	}
	
	func testError() async throws {
		let store = KeyIterableStore<Void, String, Int>.error(ValueStoreError.noData)
		
		do {
			let loaded = try await store.load("key")
			XCTFail("Unexpected value \(loaded). Should have returned an error.")
		}
		catch ValueStoreError.noData { }
		catch let error {
			XCTFail("Unexpected error \(error). Should have failed with a ValueStoreError.noData.")
		}
		
		do {
			let saved = try await store.save("key", 42)
			XCTFail("Unexpected value \(saved). Should have returned an error.")
		}
		catch ValueStoreError.noData { }
		catch let error {
			XCTFail("Unexpected error \(error). Should have failed with a ValueStoreError.noData.")
		}
		
		do {
			let loadedAfterSave = try await store.load("key")
			XCTFail("Unexpected value \(loadedAfterSave). Should have returned an error.")
		}
		catch ValueStoreError.noData { }
		catch let error {
			XCTFail("Unexpected error \(error). Should have failed with a ValueStoreError.noData.")
		}

		do {
			try await store.remove("key")
			XCTFail("Unexpected removal without error.")
		}
		catch ValueStoreError.noData { }
		catch let error {
			XCTFail("Unexpected error \(error). Should have failed with a ValueStoreError.noData.")
		}
	}
	
	func testReplacingMove() async throws {
		let key = "key"
		let oldRef = Reference<[String: Int]>([key: 7])
		let old = oldRef.keyIterableStore()
		let store = Reference<[String:Int]>().keyIterableStore().replacing(old)
		
		let fromOld = try await store.load(key)
		
		XCTAssertEqual(fromOld, 7)
		XCTAssertEqual(oldRef.value, [:])
		
		_ = try await store.save(key, 42)
		XCTAssertEqual(oldRef.value, [:])
		
		let saved = try await store.load(key)
		XCTAssertEqual(saved, 42)
		
		try await store.remove(key)
		XCTAssertEqual(oldRef.value, [:])
		
		let afterRemove = try? await store.load(key)
		XCTAssertEqual(afterRemove, nil)
	}
	
	func testReplacingRemove() async throws {
		let key = "key"
		let oldRef = Reference<[String: Int]>([key: 7])
		let old = oldRef.keyIterableStore()
		let store = Reference<[String: Int]>().keyIterableStore().replacing(old)
		
		try await store.remove(key)
		XCTAssertEqual(oldRef.value, [:])

		let afterRemove = try? await store.load(key)
		XCTAssertEqual(afterRemove, nil)
	}
	
	func testCreateEnvironment() async throws {
		let key = "key"

		let ref = Reference<[String: Int]>([key: 7])

		let store = KeyIterableStore<Void, String, Int> { key, environment in
			try isPresent(ref.value?[key], or: ValueStoreError.noData)
		} save: { key, value, environment in
			ref.value?[key] = value
			return value
		} remove: { key, environment in
			ref.value?[key] = nil
		} allKeys: {
			ref.value?.keys.map { $0 } ?? []
		}

		try await store.testCycle(key, value: 7)
	}
	
	func testCreateVoidEnvironment() async throws {
		let key = "key"

		let ref = Reference<[String: Int]>([key: 7])

		let store = KeyIterableStore { key in
			try isPresent(ref.value?[key], or: ValueStoreError.noData)
		} save: { key, value in
			ref.value?[key] = value
			return value
		} remove: { key in
			ref.value?[key] = nil
		} allKeys: {
			ref.value?.keys.map { $0 } ?? []
		}

		try await store.testCycle(key, value: 7)
	}
}
