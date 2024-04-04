# Constructors

## const

A ValueStore that will always have the save value. It doesn’t throw errors, but saving and removing are ignored. Useful for testing purposes.

Example:

```swift
persistence.preference1 = .const(true)
```

## error

A ValueStore that will always throw. Loading, saving and removing always throw the error we use when creating it. Useful for testing purposes.

Example:

```swift
persistence.preference1 = .error(MyError.noData)
```
