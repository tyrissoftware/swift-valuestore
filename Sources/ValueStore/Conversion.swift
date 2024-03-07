import Foundation

public struct Conversion<Input, Output> {
	public var to: (Input) -> Output
	public var from: (Output) -> Input
	
	public init(
		to: @escaping (Input) -> Output,
		from: @escaping (Output) -> Input
	) {
		self.to = to
		self.from = from
	}
}
