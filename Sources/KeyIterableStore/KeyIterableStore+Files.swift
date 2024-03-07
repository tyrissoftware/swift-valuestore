import Foundation

import ValueStore
import IndexedStore

extension KeyIterableStore where Environment == Void, Key == String, Value == Data {
	/// Use a folder for storage, taking the key as the file name
	public static func folder(
		_ folderUrl: URL,
		fileManager: FileManager = .default
	) -> KeyIterableStore<Void, String, Data> {
		.init(
			indexed: .folder(folderUrl, fileManager: fileManager),
			allKeys: {
				(try? fileManager.contentsOfDirectory(atPath: folderUrl.path)) ?? []
			}
		)
	}
}

extension KeyIterableStore where Value: Codable, Key == String, Environment == Void {
	public static func jsonFolder(
		_ url: URL,
		fileManager: FileManager = .default,
		encoder: JSONEncoder = .init(),
		decoder: JSONDecoder = .init()
	) -> KeyIterableStore<Void, Key, Value> {
		KeyIterableStore<Void, Key, Data>.folder(url, fileManager: fileManager)
			.coded(.jsonCodec(decoder, encoder))
	}
}
