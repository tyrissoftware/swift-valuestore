import Foundation

extension ValueStore {
	public static func const(
		_ value: Value
	) -> Self {
		.init { _ in
			value
		} save: { _, _ in
			value
		} remove: { _ in
			()
		}
	}
	
	public static func error(
		_ error: Error
	) -> Self {
		.init { _ in
			throw(error)
		} save: { _, _ in
			throw(error)
		} remove: { _ in
			throw(error)
		}
	}
	
	public func replacing(
		_ oldStore: ValueStore<Environment, Value>
	) -> Self {
		.init { environment in
			do {
				let result = try await self.load(environment)
				try? await oldStore.remove(environment)
				return result
			}
			catch {
				return try await oldStore.move(to: self, environment: environment)
			}
		} save: { value, environment in
			try await self.save(value, environment)
		} remove: { environment in
			try await self.remove(environment)
			try? await oldStore.remove(environment)
		}
	}
}
