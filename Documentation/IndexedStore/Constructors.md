# Constructors

## const

An IndexedStore that will always have the save value for all keys. It doesn’t throw errors, but saving and removing are ignored. Useful for testing purposes.

Example:

```swift
let store = IndexedStore<Void, String, Bool>.const(true)
```

## error

An IndexedStore that will always throw, no matter the key used. Loading, saving and removing always throw the error we use when creating it. Useful for testing purposes and mocks.

Example:

```swift
let store = IndexedStore<Void, String, Bool>.error(MyError.noData)
```
