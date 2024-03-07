import Foundation

extension KeyIterableStore {
	public func clear(
		environment: Environment
	) async throws {
		for key in self.allKeys() {
			try await self.indexed.remove(key, environment)
		}
	}
	
	public func loadValues(environment: Environment) async throws -> [Value] {
		var result: [Value] = []
		for key in self.allKeys() {
			let value = try await self.load(key, environment)
			result.append(value)
		}
		return result
	}
}

extension KeyIterableStore where Environment == Void {
	public func clear() async throws {
		try await self.clear(environment: ())
	}
	
	public func loadValues() async throws -> [Value] {
		try await self.loadValues(environment: ())
	}
}
