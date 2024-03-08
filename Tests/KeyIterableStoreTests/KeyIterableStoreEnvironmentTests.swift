import Foundation
import XCTest

import ValueStore
import IndexedStore
import KeyIterableStore

class KeyIterableStoreEnvironmentTests: XCTestCase {
	func testProvide() async throws {
		let token = "AuthToken"
		
		let key = "key"
		var values = [key: 7]
		let indexed = IndexedStore<String, String, Int> { key, token in
			try isPresent(values[key], or: ValueStoreError.noData)
		} save: { key, newValue, token in
			values[key] = newValue
			return try isPresent(values[key], or: ValueStoreError.noData)
		} remove: { key, token in
			values[key] = nil
		}
		let store = KeyIterableStore(
			indexed: indexed,
			allKeys: { values.keys.map { $0 } }
		)

		try await store.provide(token).testCycle(key, value: 42)
	}
	
	func testPullback() async throws {
		struct Auth {
			var token: String
		}
		
		let key = "key"
		var values = [key: 7]
		let indexed = IndexedStore<String, String, Int> { key, token in
			try isPresent(values[key], or: ValueStoreError.noData)
		} save: { key, newValue, token in
			values[key] = newValue
			return try isPresent(values[key], or: ValueStoreError.noData)
		} remove: { key, token in
			values[key] = nil
		}
		
		let store: KeyIterableStore<Auth, String, Int> = KeyIterableStore<String, String, Int>(
			indexed: indexed,
			allKeys: { values.keys.map { $0 } }
		)
		.pullback(\Auth.token)

		let auth = Auth(token: "token")
		
		try await store.provide(auth).testCycle(key, value: 42)
	}
	
	func testRequire() async throws {
		let key = "key"

		let store = Reference<[String: Int]>().keyIterableStore().require(String.self)
		
		try await store.provide("ignored").testCycle(key, value: 42)
	}
}
