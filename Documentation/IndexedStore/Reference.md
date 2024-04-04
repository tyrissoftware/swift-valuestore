# Using Reference with IndexedStore

See also: [Reference](/Documentation/ValueStore/Reference.md) in ValueStore.

Since an IndexedStore is basically a generalization of a Dictionary, we can easily construct one if we have a Dictionary reference:

```swift
let reference = Reference<[Int: String]>()
let store = reference.indexedStore()
```

## Testing example
The following test case shows how to move a value from a source store to a target store, to test it easy we are going to use the Reference. Instead of use the UsersDefaults as a value storing place. With the Reference we can get a ValueStore with the same result type than our Production-like instance, so we can pass as a dependency to the instances that requieres to test it with the in-memory storage, instead of using the real one.

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
