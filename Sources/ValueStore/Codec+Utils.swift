import Foundation

extension Codec {
	public func reversed() -> Codec<Output, Input> {
		.init(to: self.from, from: self.to)
	}
}

extension Codec {
	public func combine<Output2>(with codec: Codec<Output, Output2>) -> Codec<Input, Output2> {
		.init { input in
			let output = try self.to(input)
			return try codec.to(output)
		} from: { output2 in
			let output = try codec.from(output2)
			return try self.from(output)
		}
	}
}
