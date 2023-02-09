import Foundation
import XCTest
import ValueStore

class ValueStoreUserDefaultsTests: XCTestCase {
	func testUserDefaults() async throws {
		let store = ValueStore<Void, String>.unsafeRawUserDefaults("key")
		
		try await store.testCycle("hello!")
	}
	
	func testJSON() async throws {
		struct User: Equatable, Codable {
			var name: String
		}
		
		let john = User(name: "John")
		
		let store = ValueStore<Void, User>.unsafeJSONUserDefaults("user")
		try await store.testCycle(john)
	}
}
