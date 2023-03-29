import Foundation

extension ReferenceWritableKeyPath {
	public func valueStore<Wrapped>() -> ValueStore<Root, Wrapped>
	where Value == Optional<Wrapped> {
		ValueStore { root in
			try isPresent(
				root[keyPath: self],
				or: ValueStoreError.noData
			)
		} save: { value, root in
			root[keyPath: self] = value
			return value
		} remove: { root in
			root[keyPath: self] = nil
		}
	}
}
