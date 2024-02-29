# Reference for wrapping a Value Store
*Reference* is a simple class that wraps a value. It can be used to easily introduce a reference type and store values in memory. It can be useful in production, but also for testing or mocking. It enables testing in isolation from other persistent storage mechanisms like UserDefaults. By utilizing in-memory storage, tests can be **performed without side effects**, ensuring a clean state before and after test runs.

## Testing example
The following test case shows how to move a value from a source store to a target store. To easily test it we are going to use Reference instead of using UsersDefaults as the backing storage. With Reference we can get a ValueStore with the same result type than our Production-like instance, so we can pass as a dependency to the instances that requieres to test it with the in-memory storage, instead of using the real one.

```swift
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
```

Consider the scenario where you need to test an API request that retrieves user favorites based on stored IDs. In a production environment, these IDs might be stored in UserDefaults, but for testing, we'll wrap them using an in-memory Reference.

```swift 
func searchFunctionalTest() async throws {
    // Wrap favorite item IDs in an in-memory store
    let tokenValueStoreWrapped = Reference<[String]>(["id-1", "id-2", "id-3"]).valueStore
    
    // Perform the API request using the wrapped value store
    let result = try await getFavoritesBy(favoritesValueStore: tokenValueStoreWrapped)
    XCTAssertEqual(result, ["name-1", "name-2", "name-3"])
}

func getFavoritesBy(favoritesValueStore: ValueStore<[String], Void>) async throws -> [String] {
    // Simulate an API request that fetches favorite items based on stored IDs
    // In a real implementation, this function would perform network operations
    return ["name-1", "name-2", "name-3"]
}
```
