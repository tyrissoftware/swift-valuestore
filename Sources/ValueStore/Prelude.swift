import Foundation

public func isPresent<Value>(
	_ value: Value?,
	or error: Error
) throws -> Value {
	guard let value = value else {
		throw error
	}
	
	return value
}
