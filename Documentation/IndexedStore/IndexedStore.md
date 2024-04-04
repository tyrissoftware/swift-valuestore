# IndexedStore

An IndexedStore is a general interface for Dictionary-like functionality. You can load, save and remove values with an index or key, and you might also require an Environment for these operations.

```swift
let store = IndexedStore(
	load: { key, environment in
		…
	},
	save: { key, value, environment
		…
	},
	remove: { key, environment in
		…
	}
)

let loaded = try await store.load(.key1)
let updated = try await store.save(.key2, newValue)
try await store.remove(.key3)
```
