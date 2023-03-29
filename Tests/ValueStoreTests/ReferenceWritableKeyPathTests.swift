import Foundation
import XCTest
import ValueStore

class Reference {
	var value: Int?
	init(value: Int? = nil) {
		self.value = value
	}
}

class ReferenceWritableKeyPathTests: XCTestCase {
	func testReferenceWritableKeyPath() async throws {
		let ref = Reference()
		let valueStore = (\Reference.value).valueStore().provide(ref)
		try await valueStore.testCycle(7)
	}
}
