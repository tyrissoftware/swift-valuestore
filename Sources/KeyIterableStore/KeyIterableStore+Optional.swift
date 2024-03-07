import Foundation

extension KeyIterableStore {
	public func set(
		_ key: Key,
		_ value: Value?,
		environment: Environment
	) async throws {
		guard let value = value else {
			try await self.remove(key, environment)
			return
		}
		
		_ = try await self.save(key, value, environment)
	}
}

extension KeyIterableStore where Environment == Void {
	public func set(
		_ key: Key,
		_ value: Value?
	) async throws {
		try await self.set(key, value, environment: ())
	}
}
