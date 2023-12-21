import Foundation

public actor Ref<Value> {
	public var value: Value?
	
	public init(
		_ value: Value? = nil
	) {
		self.value = value
	}
	
	public func change(to value: Value?) {
		self.value = value
	}
}

extension Ref {
	nonisolated public var valueStore: ValueStore<Void, Value> {
		ValueStore { _ in
			try await isPresent(self.value, or: ValueStoreError.noData)
		} save: { value, _ in
			await self.change(to: value)
			return value
		} remove: { _ in
			await self.change(to: nil)
		}
	}
}
