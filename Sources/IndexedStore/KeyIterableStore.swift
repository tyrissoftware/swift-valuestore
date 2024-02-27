import Foundation

public struct KeyIterableStore<Environment, Key: Hashable, Value> {
	public var indexed: IndexedStore<Environment, Key, Value>
	public var allKeys: [Key]
	
	public init(
		indexed: IndexedStore<Environment, Key, Value>,
		allKeys: [Key]
	) {
		self.indexed = indexed
		self.allKeys = allKeys
	}
	
	public init(
		load: @escaping (Key, Environment) async throws -> Value,
		save: @escaping (Key, Value, Environment) async throws -> Value,
		remove: @escaping (Key, Environment) async throws -> Void,
		allKeys: [Key]
	) {
		self.init(
			indexed: .init(
				load: load,
				save: save,
				remove: remove
			),
			allKeys: allKeys
		)
	}
}
