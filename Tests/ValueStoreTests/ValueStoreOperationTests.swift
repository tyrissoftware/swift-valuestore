import Foundation
import XCTest
import ValueStore

class ValueStoreOperationTests: XCTestCase {
    func testCopy() async throws {
        let source = Reference<Int?>(7).valueStore
        let target = Reference<Int?>().valueStore
        
        let copied = try await source.copy(to: target)
        XCTAssertEqual(copied, 7)
        
        let sourceValue = try await source.load()
        XCTAssertEqual(sourceValue, 7)
        
        let targetValue = try await target.load()
        XCTAssertEqual(targetValue, 7)
    }
    
    func testMove() async throws {
        let source = Reference<Int?>(7).valueStore
        let target = Reference<Int?>().valueStore
        
        let copied = try await source.move(to: target)
        XCTAssertEqual(copied, 7)
        
        let sourceValue = try? await source.load()
        XCTAssertEqual(sourceValue, nil)
        
        let targetValue = try await target.load()
        XCTAssertEqual(targetValue, 7)
    }
    
    func testCache() async throws {
        let slow = Reference<Int?>(7).valueStore
        let fast = Reference<Int?>(1).valueStore
        
        let store = slow.cached(by: fast)
        
        let cached = try await store.load()
        
        XCTAssertEqual(cached, 1)
        
        try await store.testCycle(22)
    }
    
    func testCached() async throws {
        let store = Reference<Int?>(7).valueStore
        
        let valueCached = try await store.cached(load: { 1 }, environment: ())
        XCTAssertEqual(valueCached, 7)
        
        try await store.remove()
        
        let valueNotCached = try await store.cached(load: { 11 }, environment: ())
        XCTAssertEqual(valueNotCached, 11)
        
    }
}
