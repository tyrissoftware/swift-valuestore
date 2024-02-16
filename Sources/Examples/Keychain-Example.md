### Storing in keychain using Valet

To begin, we need to define keys for the new ValueStore:

```swift
public enum KeychainKey: String {
    case userAuth
}
```

Next, we extend ValueStore to support keychain storage for Codable values. This extension utilizes UTF8 and JSON encoding provided by the ValueStore library:

```swift
public extension ValueStore where Value: Codable {
    static func keychain(
        _ key: KeychainKey,
        prefix: String = ""
    ) -> ValueStore<Void, Value> {
        ValueStore<Void, String>.keychain(key, prefix: prefix)
            .coded(Codec.utf8.reversed())
            .coded(Codec.json)
    }
}

```
This method ensures secure storage of Codable objects in the keychain.
Finally, we implement keychain interaction functionality using the **Valet library**. This includes methods for loading, saving, and removing data associated with specific keys:

```swift 
import Valet
import ValueStore

public extension ValueStore where Value == String {
    private static var valet: Valet {
        Valet.valet(with: Identifier(nonEmpty: "User")!, accessibility: .whenUnlocked)
    }
    
    private static func valetKey(
        _ key: KeychainKey,
        _ prefix: String = ""
    ) -> String {
        "\(prefix)\(key)"
    }
    
    static func keychain(
        _ key: KeychainKey,
        prefix: String = ""
    ) -> ValueStore<Void, Value> {
        .init(
            load: { _ in
                guard
                    let value = self.valet.string(forKey: valetKey(key, prefix))
                else {
                    throw(ValueStoreError.noData)
                }
                
                return value
            },
            save: { value, _ in
                self.valet.set(
                    string: value,
                    forKey: valetKey(key, prefix)
                )
                
                return value
            },
            remove: {
                self.valet.removeObject(forKey: valetKey(key, prefix))
            }
        )
    }
}
```
In this extension, we define a private Valet instance for secure storage and methods for creating keychain keys. The keychain method provides a ValueStore specifically for keychain operations, handling loading, saving, and removing string values securely.

