# swift-valuestore

📦 An interface for storing values in a general way. Improves upon UserDefaults in a number of ways.

---

* [Motivation](#Motivation)
* [Getting started](#Getting-started)
* [Documentation](#Documentation)
* [License](#License)

## Learn More

## Motivation

UserDefaults are very useful and easy to use, however, they have many issues and shortcomings that are usually not discussed. You shouldn’t use them directly in your code if you want testability, type safety and to allow these values to be stored in different places.

This library provides a type: ValueStore, which allows to store your values into the UserDefaults, memory, the file system or any other final storage, while abstracting the usage from the specific implementation you want to use in your live environment.


## Getting Started

To use the library you define a struct to hold all the persisted values:

```swift
struct PersistenceEnvironment {
	var userPreference1: ValueStore<Void, String>
	var userPreference2: ValueStore<Void, Int>
	var networkPreference: ValueStore<NetworkEnvironment, String>
}
```

Now we should create an enum to hold all the keys to be used with UserDefaults:

```swift
enum UserDefaultsKey: String {
	case userPreference1
	case userPreference2
}
```

This way the compiler will ensure that all keys are unique. Now we need to create a constructor that will use this key:

```swift
extension ValueStore {
    static func userDefaults(_ key: UserDefaultsKey) -> Self {
        .unsafeRawUserDefaults(key.rawValue)
    }
}
```

You can also have other implementations that store the value using an endpoint, the keychain or whatever:

```swift
extension ValueStore where Environment == NetworkEnvironment {
    static func network(_ endpoint: String) -> Self {
        .init(
            load: { networkEnvironment in
                try await get(...)
            },
            save: { value, networkEnvironment in 
                try await post(...)
            },
            remove: { networkEnvironment in 
                try await delete(...)
            }
        )
    }
}
```

Now we can create a live version of our PersistenceEnvironment: 

```swift
extension PersistenceEnvironment {
	static var live: Self {
		.init(
			userPreference1: .userDefaults(.userPreference1),
			userPreference2: .userDefaults(.userPreference2), 
			networkPreference: .network(“preference”)
		)
	}
}
```

Finally you can use these stores to read and write your values:

```swift
let environment = PersistenceEnvironment.live

var storedPreference1 = try await environment.userPreference1.load()
storedPreference1 += “!”
try await environment.userPreference1.save(storedPreference1)
```

Check the documentation or the tests for a better understanding on how to use it, and all the utilities that come with ValueStore.

## Documentation

The documentation can be found in the "Documentation" folder.

## License

This library is released under the MIT license.
