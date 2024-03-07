import Foundation
import XCTest

import ValueStore
import IndexedStore

class IndexedStoreFilesTests: XCTestCase {
	func testFolder() async throws {
		let tmpPath = FileManager.default.temporaryDirectory
		let url = tmpPath.appendingPathComponent("testFolder")
		
		let store = IndexedStore.folder(url).coded(Codec.utf8)
		
		try await store.testCycle("file", value: "Hello world!")
		
		try FileManager.default.removeItem(atPath: url.path())
	}
	
	func testJSONFolder() async throws {
		struct User: Equatable, Codable {
			var name: String
		}
		
		let tmpPath = FileManager.default.temporaryDirectory
		let url = tmpPath.appendingPathComponent("testJSONFolder")
		
		let store = IndexedStore<Void, String, User>.jsonFolder(url)
		
		let user = User(name: "John")
		
		try await store.testCycle("user", value: user)
		
		try FileManager.default.removeItem(atPath: url.path())
	}
}
