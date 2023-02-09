import Foundation
import XCTest
import ValueStore

class CodecTests: XCTestCase {
	func testCodec() throws {
		struct User: Equatable, Codable {
			var name: String
		}
		
		let codec = Codec<User, Data>.json
		
		let john = User(name: "John")
		
		try codec.testCycle(john)
	}
	
	func testURL() throws {
		let codec = Codec<URL, String>.url
		
		let url = URL(string: "https://www.google.com")!
		try codec.testCycle(url)
	}
	
	func testMapError() throws {
		struct User: Equatable, Codable {
			var name: String
		}
		
		let codec = Codec<User, Data>.error(CodecError.encoding)
			.mapError { _ in
				ValueStoreError.noData
			}
		
		let john = User(name: "John")
		
		do {
			_ = try codec.to(john)
		}
		catch ValueStoreError.noData {
		}
		catch let error {
			XCTFail("Unexpected error \(error)")
		}
		
		do {
			_ = try codec.from(Data())
		}
		catch ValueStoreError.noData {
		}
		catch let error {
			XCTFail("Unexpected error \(error)")
		}
	}
	
	func testMapErrorNoError() throws {
		struct User: Equatable, Codable {
			var name: String
		}
		
		let codec = Codec<User, Data>.jsonCodec()
			.mapError { _ in
				ValueStoreError.noData
			}
		
		let john = User(name: "John")
		
		
		let data = try codec.to(john)
		let recovered = try codec.from(data)
		
		XCTAssertEqual(john, recovered)
	}
}
