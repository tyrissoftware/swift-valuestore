import Foundation

extension ValueStore {
	@inlinable
	public func coded<NewValue>(
		_ codec: Codec<NewValue, Value>
	) -> ValueStore<Environment, NewValue> {
		self.process { newValue in
			try codec.to(newValue)
		} postprocess: { value in
			try codec.from(value)
		}
	}
}

extension ValueStore {
	@inlinable
	public func representing<NewValue>(by: NewValue.Type) -> ValueStore<Environment, NewValue>
	where NewValue: RawRepresentable, NewValue.RawValue == Value {
		self.coded(.representing)
	}
}
