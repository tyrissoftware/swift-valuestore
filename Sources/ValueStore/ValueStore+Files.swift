import Foundation

extension ValueStore where Environment == Void, Value == Data {
	public static func file(
		_ url: URL,
		fileManager: FileManager = .default
	) -> ValueStore<Void, Data> {
		.init {
			try Data(contentsOf: url)
		} save: { data in
			try data.write(to: url)
			return data
		} remove: {
			try fileManager.removeItem(at: url)
		}
	}
}

extension ValueStore where Value: Codable, Environment == Void {
	public static func jsonFile(
		_ url: URL,
		fileManager: FileManager = .default,
		encoder: JSONEncoder = .init(),
		decoder: JSONDecoder = .init()
	) -> ValueStore<Void, Value> {
		ValueStore<Void, Data>.file(url, fileManager: fileManager)
			.coded(.jsonCodec(decoder, encoder))
	}
}
