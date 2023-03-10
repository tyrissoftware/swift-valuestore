import Foundation

extension Codec where Input == String, Output == Data {
	public static var utf8: Codec<Input, Output> {
		.init { string in
			try isPresent(string.data(using: .utf8), or: CodecError.encoding)
		} from: { data in
			try isPresent(String(data: data, encoding: .utf8), or: CodecError.encoding)
		}
	}
}

extension Codec where Input == URL, Output == String {
	public static var url: Codec<Input, Output> {
		.init { url in
			url.absoluteString
		} from: { string in
			try isPresent(URL(string: string), or: CodecError.encoding)
		}
	}
}

extension Codec where Input: RawRepresentable, Input.RawValue == Output {
	public static var represented: Self {
		.init {
			$0.rawValue
		} from: {
			try isPresent(.init(rawValue: $0), or: CodecError.encoding)
		}
	}
}
