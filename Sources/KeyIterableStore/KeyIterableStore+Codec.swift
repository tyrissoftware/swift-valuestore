import Foundation

import ValueStore

extension KeyIterableStore {
	@inlinable
	public func coded<NewValue>(
		_ codec: Codec<NewValue, Value>
	) -> KeyIterableStore<Environment, Key, NewValue> {
		self.process { newValue in
			try codec.to(newValue)
		} postprocess: { value in
			try codec.from(value)
		}
	}
}

extension KeyIterableStore {
	@inlinable
	public func representing<NewValue>(by: NewValue.Type) -> KeyIterableStore<Environment, Key, NewValue>
	where NewValue: RawRepresentable, NewValue.RawValue == Value {
		self.coded(.representing)
	}
}
