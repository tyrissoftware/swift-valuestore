import Foundation

@available(*, deprecated, message: "Use Reference<Value> instead")
public typealias Ref<Value> = Reference<Value>

public final class Reference<Value> {
	public var value: Value?
	
	public init(
		_ value: Value? = nil
	) {
		self.value = value
	}
}

extension Reference {
	public var valueStore: ValueStore<Void, Value> {
		ValueStore { _ in
			try isPresent(self.value, or: ValueStoreError.noData)
		} save: { value, _ in
			self.value = value
			return value
		} remove: { _ in
			self.value = nil
		}
	}
}
