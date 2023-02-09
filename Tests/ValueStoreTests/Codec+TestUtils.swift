import XCTest
import ValueStore

extension Codec where Input: Equatable {
	func testCycle(_ input: Input) throws {
		let output = try self.to(input)
		let input2 = try self.from(output)
		
		XCTAssertEqual(input, input2)
	}
}
