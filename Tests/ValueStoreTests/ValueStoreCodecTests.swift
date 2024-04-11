import Foundation
import XCTest
import ValueStore

enum StringEnum: String {
	case one
	case two
	case three
}

class ValueStoreCodecTests: XCTestCase {
	func testRepresented() async throws {
		let ref = Reference<String>()
		let store = ref.valueStore.representing(by: StringEnum.self)
		
		let saved = try await store.save(.one)
		let loaded = try await store.load()
		
		XCTAssertEqual(loaded, saved)
		XCTAssertEqual(loaded, .one)
	}
	
	func testRepresentedInvalid() async throws {
		let ref = Reference<String>("blah")
		let store = ref.valueStore.representing(by: StringEnum.self)
		
		do {
			let value = try await store.load()
			XCTFail("Unexpected value loaded: \(value)")
		}
		catch CodecError.encoding {
			
		}
		catch {
			XCTFail("Unexpected error")
		}
	}
}
