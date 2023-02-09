import Foundation
import XCTest
import ValueStore

class ValueStoreEnvironmentTests: XCTestCase {
	func testProvide() async throws {
		let token = "AuthToken"
		
		var value: Int? = 7
		let store = ValueStore<String, Int> { token in
			try isPresent(value, or: ValueStoreError.noData)
		} save: { newValue, token in
			value = newValue
			return try isPresent(value, or: ValueStoreError.noData)
		} remove: { token in
			value = nil
		}

		try await store.provide(token).testCycle(42)
	}
	
	func testPullback() async throws {
		struct Auth {
			var token: String
		}
		
		var value: Int? = 7
		let store: ValueStore<Auth, Int> = ValueStore<String, Int> { token in
			try isPresent(value, or: ValueStoreError.noData)
		} save: { newValue, token in
			value = newValue
			return try isPresent(value, or: ValueStoreError.noData)
		} remove: { token in
			value = nil
		}
		.pullback(\Auth.token)

		let auth = Auth(token: "token")
		
		try await store.provide(auth).testCycle(42)
	}
	
	func testRequire() async throws {
		let store = Ref<Int>(nil).valueStore.require(String.self)
		
		try await store.provide("ignored").testCycle(42)
	}
}
