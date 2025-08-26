import Foundation

import ValueStore

class Observer<Value>: NSObject {
	let continuation: AsyncStream<Value>.Continuation
	
	init(
		continuation: AsyncStream<Value>.Continuation
	) {
		self.continuation = continuation
		super.init()
	}
}

public extension ObservableStore where Value: PropertyListValue {
	static func unsafeRawUserDefaults(
		_ key: String,
		userDefaults: UserDefaults = .standard
	) -> ObservableStore<Environment, Value> {
		
		
		
		return .init(
			store: .unsafeRawUserDefaults(
				key, 
				userDefaults: userDefaults
			),
			updates: stream
		)
	}
}
