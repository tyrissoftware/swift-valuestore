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

### Features
**Type Safety**: Ensure that values are stored and retrieved in a consistent and safe manner, reducing runtime errors and improving code quality.
**Abstraction Layer**: Abstract away the details of underlying storage mechanisms, allowing for easy swapping or modification of storage solutions without affecting the rest of your code.
**Flexibility**: Store values in UserDefaults, memory, file system, or any custom storage solution of your choice.
**Testability**: Designed with testability in mind, making it easier to write unit tests for code that involves value storage.
**Ease of Use**: Simple and intuitive API that integrates seamlessly with your Swift projects.

## Getting Started

The recommended way to use the library is to define a **Persistence struct**, is where we store the multiple ValueStore instances, each responsible for handling a specific type of data in your application. Here is an overview of how to set up and use the Persistence structure:
```swift 
public struct Persistence {
    public var settings: ValueStore<Void, Settings>
    public var language: ValueStore<Void, String>
}
```

In this persistence struct we are going to store an implementation that resolves all the persistence operations of the property.

Using this struct we can now create the live instance to be used in production.

```swift
extension Persistence {
    public static func live() -> Self {
        .init(
            settings: .userDefaults(.settings),
            language: .userDefaults(.language)
        )
    }
}
```

In this extension, we define a static method **live()** that returns an instance of Persistence. This instance is initialized with specific ValueStore types for different data categories. We use **.userDefaults** to specify the storage mechanism for each type of data:

For each ValueStore, we pass an associated enum value that represents the key for storing that particular piece of data. For example:

### Storing in UsersDefault
Let's implement the settings and the language storing in the UserDefaults. This use case is the most simpler for what the library was created. To do it, we need a enum to define the keys and we need to create our ValueStore. To invoque this value store we will use the **static func userDefaults**. 

```swift
public enum UserDefaultsKey: String {
	case settings
    case language
}

extension ValueStore where Value: Codable {
	public static func userDefaults(
		_ key: UserDefaultsKey
	) -> ValueStore<Environment, Value> {
		ValueStore.unsafeJSONUserDefaults(key.rawValue)
	}
}
```
That's it with the following code the live instance will work for the keys settings and language.

The ValueStore unsafeJSONUserDefaults it's defined in our library and you can use it to store in users defaults in JSON format. For this reason we don't need to do nothing more. 

Why store at users default in a JSON format? That's a good question. Its because by default the types that UsersDefaults supports are restricted to a few system types (URL not included). For this reason we encourage you to use **unsafeJSONUserDefaults**. But if you want to store values in the native format you can do it using the ValueStore compatible with it, furthermore, we typed the system types compatible with the Value Store to avoid any error using it. If you want to use it, you only need to call to **unsafeRawUserDefaults** insted and build a value store with one of the compatible types. (Check types at ValueStore+UserDefaults.swift).

### Mocking the Persistance and the ValueStores
We can create another instance of the Persistance struct to the testing or preview environment like that

```swift
extension Persistence {
	public static var mock: Self {
		.init(
			settings: .const(Settings.mock()),
			userAuth: ValueStore<Void, UserAuth>.const(
				UserAuth.mock()
			),
            language: .const("es")
		)
	}
}
```

- The const constructor will return a ValueStore that will be constant, no changes will be perform in the ValueStore created using the .const constructor (Defined in ValueStore+Creation.swift)
- Settings.mock() and UserAuth.mock() will turn back a instance for mock environment of this structs.

That's it, with this we have a Persistence instance that will turn back the desired mocked data that we defined.

### Using the Value Stores
Finally you can use these stores to read and write your values:

```swift
let environment = Persistance.live

var lang = try await environment.language.load()
lang = “es”
try await environment.language.save(lang)
```

Check the documentation or the tests for a better understanding on how to use it, and all the utilities that come with ValueStore.

### Documentation

The documentation can be found in the "Documentation" folder.

#### ValueStore

- [**Codec**](Documentation/ValueStore/Codec.md): This page will explain you how the codec works, used for the transformation between the aplication typed value and the stored format value.

- [**Constructors**](Documentation/ValueStore/Constructors.md): A more detailed explanation about how to construct diferent kind of ValueStores.

- [**Files**](Documentation/ValueStore/Files.md): You can store the data into a file instead of at UsersDefault.

- [**User Defaults**](Documentation/ValueStore/UserDefaults.md): You can store the data into a file instead of at UsersDefault.

- [**Utilities**](Documentation/ValueStore/Utilities.md): A bunch of methods useful to handle your ValueStores.

- [**Reference**](Documentation/ValueStore/Reference.md): Good practices about how to mock a ValueStore for testing or mocking purpuses

#### IndexedStore

- [**Constructors**](Documentation/IndexedStore/Constructors.md): Explains some implementations that come with IndexedStore.


### Code examples

Explore the code examples located in the folder Sources/Examples to gain inspiration on leveraging the ValueStore library for various purposes.

- [**Keychain with Valet integration**](Sources/Examples/Keychain-Example.md): A code example of how to use ValueStore to connect with the keychain using the Valet library.

## License

This library is released under the MIT license.
