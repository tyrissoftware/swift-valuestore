import Foundation

extension ValueStore {
	public func set(
		_ value: Value?,
		environment: Environment
	) async throws {
		guard let value = value else {
			try await self.remove(environment)
			return
		}
		
		_ = try await self.save(value, environment)
	}
}

extension ValueStore where Environment == Void {
	public func set(
		_ value: Value?
	) async throws {
		try await self.set(value, environment: ())
	}
}
