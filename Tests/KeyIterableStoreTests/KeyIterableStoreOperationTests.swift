import Foundation
import XCTest

import ValueStore
import IndexedStore
import KeyIterableStore

class KeyIterableStoreOperationTests: XCTestCase {
	func testCopy() async throws {
		let key = "key"
		let source = Reference<[String: Int]>([key: 7]).keyIterableStore()
		let target = Reference<[String: Int]>().keyIterableStore()
		
		let copied = try await source.copy(key, to: target)
		XCTAssertEqual(copied, 7)
		
		let sourceValue = try await source.load(key)
		XCTAssertEqual(sourceValue, 7)
		
		let targetValue = try await target.load(key)
		XCTAssertEqual(targetValue, 7)
	}
	
	func testMove() async throws {
		let key = "key"
		let source = Reference<[String: Int]>([key: 7]).keyIterableStore()
		let target = Reference<[String: Int]>().keyIterableStore()

		let copied = try await source.move(key, to: target)
		XCTAssertEqual(copied, 7)
		
		let sourceValue = try? await source.load(key)
		XCTAssertEqual(sourceValue, nil)
		
		let targetValue = try await target.load(key)
		XCTAssertEqual(targetValue, 7)
	}
	
	func testCache() async throws {
		let key = "key"
		let slow = Reference<[String: Int]>([key: 7]).keyIterableStore()
		let fast = Reference<[String: Int]>([key: 1]).keyIterableStore()

		let store = slow.cached(by: fast)
		
		let cached = try await store.load(key)
		
		XCTAssertEqual(cached, 1)
		
		try await store.testCycle(key, value: 22)
	}
	
	func testCached() async throws {
		let key = "key"
		let store = Reference<[String: Int]>([key: 7]).keyIterableStore()

		let valueCached = try await store.cached(load: { 1 }, key: key, environment: ())
		XCTAssertEqual(valueCached, 7)
		
		try await store.remove(key)
		
		let valueNotCached = try await store.cached(load: { 11 }, key: key, environment: ())
		XCTAssertEqual(valueNotCached, 11)
		
	}
}
