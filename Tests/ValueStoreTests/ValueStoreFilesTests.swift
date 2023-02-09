import Foundation
import XCTest
import ValueStore

class ValueStoreFilesTests: XCTestCase {
	func testFile() async throws {
		let tmpPath = FileManager.default.temporaryDirectory
		let url = tmpPath.appendingPathExtension("testFile")
		
		let store = ValueStore.file(url).coded(Codec.utf8)
		
		try await store.testCycle("Hello world!")
	}
	
	func testJSONFile() async throws {
		struct User: Equatable, Codable {
			var name: String
		}
		
		let tmpPath = FileManager.default.temporaryDirectory
		let url = tmpPath.appendingPathExtension("testJSONFile")
		
		let store = ValueStore<Void, User>.jsonFile(url)
		
		let user = User(name: "John")
		
		try await store.testCycle(user)
	}
}
