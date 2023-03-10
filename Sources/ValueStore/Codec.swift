import Foundation

public struct Codec<Input, Output> {
	public var to: (Input) throws -> Output
	public var from: (Output) throws -> Input
	
	public init(
		to: @escaping (Input) throws -> Output,
		from: @escaping (Output) throws -> Input
	) {
		self.to = to
		self.from = from
	}
}

extension Codec {
	public static func error(
		_ error: Error
	) -> Self {
		.init { _ in
			throw error
		} from: { _ in
			throw error
		}
	}
}

extension Codec {
	public func mapError<NewFailure: Error>(
		_ f: @escaping (Error) -> NewFailure
	) -> Codec<Input, Output> {
		.init { input in
			do {
				return try self.to(input)
			}
			catch let error {
				throw f(error)
			}
		} from: { output in
			do {
				return try self.from(output)
			}
			catch let error {
				throw f(error)
			}
		}
	}
}

extension Codec where Input: Codable, Output == Data {
	@inlinable
	public static var json: Codec<Input, Output> {
		jsonCodec(JSONDecoder(), JSONEncoder())
	}
	
	@inlinable
	public static func jsonCodec(
		_ decoder: JSONDecoder = .init(),
		_ encoder: JSONEncoder = .init()
	) -> Codec<Input, Output> {
		.init { value in
			try encoder.encode(value)
		} from: { data in
			try decoder.decode(Input.self, from: data)
		}
	}
}

public enum CodecError: Error {
	case encoding
}
