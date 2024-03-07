import Foundation
import XCTest

import ValueStore
import IndexedStore

enum StringEnum: String {
	case one
	case two
	case three
}

class IndexedStoreCodecTests: XCTestCase {
	func testRepresented() async throws {
		let key = 1
		let ref = Reference<[Int: String]>()
		let store = ref.indexedStore().representing(by: StringEnum.self)
		
		let saved = try await store.save(key, .one)
		let loaded = try await store.load(key)
		
		XCTAssertEqual(loaded, saved)
		XCTAssertEqual(loaded, .one)
	}
	
	func testRepresentedInvalid() async throws {
		let key = 1
		let ref = Reference<[Int: String]>([key: "blah"])
		let store = ref.indexedStore().representing(by: StringEnum.self)
		
		do {
			let value = try await store.load(key)
			XCTFail("Unexpected value loaded: \(value)")
		} catch CodecError.encoding {
		} catch {
			XCTFail("Unexpected error")
		}
	}
}
