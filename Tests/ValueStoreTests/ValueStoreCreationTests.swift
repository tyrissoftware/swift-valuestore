import Foundation
import XCTest
import ValueStore

class ValueStoreCreationTests: XCTestCase {
	func testConst() async throws {
		let store = ValueStore<Void, Int>.const(42)
		
		let loaded = try await store.load()
		XCTAssertEqual(loaded, 42)
		
		let saved = try await store.save(42)
		XCTAssertEqual(saved, 42)
		
		let loadedAfterSave = try await store.load()
		XCTAssertEqual(loadedAfterSave, 42)

		try await store.remove()
		
		let loadedAfterRemove = try await store.load()
		XCTAssertEqual(loadedAfterRemove, 42)
	}
	
	func testError() async throws {
		let store = ValueStore<Void, Int>.error(ValueStoreError.noData)
		
		do {
			let loaded = try await store.load()
			XCTFail("Unexpected value \(loaded). Should have returned an error.")
		}
		catch ValueStoreError.noData { }
		catch let error {
			XCTFail("Unexpected error \(error). Should have failed with a ValueStoreError.noData.")
		}
		
		do {
			let saved = try await store.save(42)
			XCTFail("Unexpected value \(saved). Should have returned an error.")
		}
		catch ValueStoreError.noData { }
		catch let error {
			XCTFail("Unexpected error \(error). Should have failed with a ValueStoreError.noData.")
		}
		
		do {
			let loadedAfterSave = try await store.load()
			XCTFail("Unexpected value \(loadedAfterSave). Should have returned an error.")
		}
		catch ValueStoreError.noData { }
		catch let error {
			XCTFail("Unexpected error \(error). Should have failed with a ValueStoreError.noData.")
		}

		do {
			try await store.remove()
			XCTFail("Unexpected removal without error.")
		}
		catch ValueStoreError.noData { }
		catch let error {
			XCTFail("Unexpected error \(error). Should have failed with a ValueStoreError.noData.")
		}
	}
	
	func testReplacingMove() async throws {
		let oldRef = Ref<Int?>(7)
		let old = oldRef.valueStore
		let store = Ref<Int?>().valueStore.replacing(old)
		
		let fromOld = try await store.load()
		
		XCTAssertEqual(fromOld, 7)
		XCTAssertEqual(oldRef.value, nil)
		
		_ = try await store.save(42)
		XCTAssertEqual(oldRef.value, nil)
		
		let saved = try await store.load()
		XCTAssertEqual(saved, 42)
		
		try await store.remove()
		XCTAssertEqual(oldRef.value, nil)
		
		let afterRemove = try? await store.load()
		XCTAssertEqual(afterRemove, nil)
	}
	
	func testReplacingRemove() async throws {
		let oldRef = Ref<Int?>(7)
		let old = oldRef.valueStore
		let store = Ref<Int?>().valueStore.replacing(old)
		
		try await store.remove()
		XCTAssertEqual(oldRef.value, nil)

		let afterRemove = try? await store.load()
		XCTAssertEqual(afterRemove, nil)
	}
}
