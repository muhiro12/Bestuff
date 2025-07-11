import SwiftUI

enum BoolAppStorageKey: String {
    case isSubscribeOn = "a018f613"
}

extension AppStorage where Value == Bool {
    init(_ key: BoolAppStorageKey) {
        self.init(wrappedValue: false, key.rawValue)
    }
}
