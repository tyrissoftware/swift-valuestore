//
//  Keychain-Example.swift
//
//
//  Created by Rubén García on 5/2/24.
//

import Valet
import ValueStore

extension ValueStore where Value == String {
    private static var valet: Valet {
        Valet.valet(with: Identifier(nonEmpty: "User")!, accessibility: .whenUnlocked)
    }
    
    private static func valetKey(
        _ key: KeychainKey,
        _ prefix: String = ""
    ) -> String {
        "\(prefix)\(key)"
    }
    
    static func keychain(
        _ key: KeychainKey,
        prefix: String = ""
    ) -> ValueStore<Void, Value> {
        .init(
            load: { _ in
                guard
                    let value = self.valet.string(forKey: valetKey(key, prefix))
                else {
                    throw(ValueStoreError.noData)
                }
                
                return value
            },
            save: { value, _ in
                self.valet.set(
                    string: value,
                    forKey: valetKey(key, prefix)
                )
                
                return value
            },
            remove: {
                self.valet.removeObject(forKey: valetKey(key, prefix))
            }
        )
    }
}
