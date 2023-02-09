import Foundation

public final class Ref<Value> {
	public var value: Value?
	
	public init(
		_ value: Value? = nil
	) {
		self.value = value
	}
}

extension Ref {
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
