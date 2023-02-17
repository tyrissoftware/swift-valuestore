# UserDefaults

Using UserDefaults directly code has many issues; it’s better to use an interface that abstracts over them. For it you will need to split each value into its own store.

## Usage

1. Create an enum for holding all your app UserDefaults keys:

```swift
enum UserDefaultsKey: String {
	case preference1
	case preference2
}
```

This way the compiler will ensure that all keys are unique.

Now implement an extension to ValueStore that uses this enum:

```swift
extension ValueStore {
    static func userDefaults(_ key: UserDefaultsKey) -> Self {
        .unsafeRawUserDefaults(key.rawValue)
    }
}
```

If you need to encode more complex objects, you can also add an extension for that:

```swift
extension ValueStore {
    static func jsonUserDefaults(_ key: UserDefaultsKey) -> Self {
        .unsafeJSONUserDefaults(key.rawValue)
    }
}
```

Now you can use this functions for creating stores that allow to save data into UserDefaults safely and more generally.

Finally, you can group all your value stores into one (or multiple) structs for organizational purposes:

```swift
struct Persistence {
	var preference1: ValueStore<Void, String>
	var preference2: ValueStore<Void, String>
	…
}
```
