import Foundation

import ValueStore

extension IndexedStore where Environment == Void, Key == String, Value == Data {
	/// Use a folder for storage, taking the key as the file name
	public static func folder(
		_ folderUrl: URL,
		fileManager: FileManager = .default
	) -> IndexedStore<Void, String, Data> {
		.init { key in
			let fileUrl = folderUrl.appendingPathComponent(key)
			return try Data(contentsOf: fileUrl)
		} save: { key, data in
			let fileUrl = folderUrl.appendingPathComponent(key)
			
			try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true)
			try data.write(to: fileUrl)
			return data
		} remove: { key in
			let fileUrl = folderUrl.appendingPathComponent(key)
			try fileManager.removeItem(at: fileUrl)
		}
	}
}

extension IndexedStore where Value: Codable, Key == String, Environment == Void {
	public static func jsonFolder(
		_ url: URL,
		fileManager: FileManager = .default,
		encoder: JSONEncoder = .init(),
		decoder: JSONDecoder = .init()
	) -> IndexedStore<Void, Key, Value> {
		IndexedStore<Void, Key, Data>.folder(url, fileManager: fileManager)
			.coded(.jsonCodec(decoder, encoder))
	}
}
