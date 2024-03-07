import Foundation

import ValueStore

extension IndexedStore {
	@inlinable
	public func coded<NewValue>(
		_ codec: Codec<NewValue, Value>
	) -> IndexedStore<Environment, Key, NewValue> {
		self.process { newValue in
			try codec.to(newValue)
		} postprocess: { value in
			try codec.from(value)
		}
	}
}

extension IndexedStore {
	@inlinable
	public func representing<NewValue>(by: NewValue.Type) -> IndexedStore<Environment, Key, NewValue>
	where NewValue: RawRepresentable, NewValue.RawValue == Value {
		self.coded(.representing)
	}
}
