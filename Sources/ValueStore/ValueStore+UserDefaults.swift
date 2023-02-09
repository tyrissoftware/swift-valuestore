import Foundation

public protocol PropertyListValue {}

extension NSData: PropertyListValue {}
extension NSString: PropertyListValue {}
extension NSNumber: PropertyListValue {}
extension NSDate: PropertyListValue {}
extension NSArray: PropertyListValue {}
extension NSDictionary: PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Array: PropertyListValue {}
extension Dictionary: PropertyListValue {}

extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Int8: PropertyListValue {}
extension Int16: PropertyListValue {}
extension Int32: PropertyListValue {}
extension Int64: PropertyListValue {}
extension UInt: PropertyListValue {}
extension UInt8: PropertyListValue {}
extension UInt16: PropertyListValue {}
extension UInt32: PropertyListValue {}
extension UInt64: PropertyListValue {}

extension Float: PropertyListValue {}
extension Double: PropertyListValue {}

public extension ValueStore where Value: PropertyListValue {
	static func unsafeRawUserDefaults(
		_ key: String,
		userDefaults: UserDefaults = .standard
	) -> ValueStore<Environment, Value> {
		.init { _ in
			try isPresent(
				userDefaults.object(forKey: key) as? Value,
				or: ValueStoreError.noData
			)
		} save: { value, _ in
			userDefaults.set(value, forKey: key)
			return value
		} remove: { _ in
			userDefaults.removeObject(forKey: key)
		}
	}
}

public extension ValueStore where Value: Codable {
	static func unsafeJSONUserDefaults(
		_ key: String,
		userDefaults: UserDefaults = .standard
	) -> ValueStore<Environment, Value> {
		ValueStore<Environment, Data>.unsafeRawUserDefaults(key, userDefaults: userDefaults)
			.coded(Codec.json.mapError(ValueStoreError.encoding))
	}
}
