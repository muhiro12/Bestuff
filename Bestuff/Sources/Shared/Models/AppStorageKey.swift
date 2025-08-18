import SwiftUI

enum BoolAppStorageKey: String {
    case isSubscribeOn = "a018f613"
    case isDebugOn = "a1B2c3D4"
}

extension AppStorage where Value == Bool {
    init(_ key: BoolAppStorageKey) {
        self.init(wrappedValue: false, key.rawValue)
    }
}

enum StringAppStorageKey: String {
    case backupImportStrategy = "bKp_ImportStrategy"
}

extension AppStorage where Value == String {
    init(_ key: StringAppStorageKey) {
        self.init(wrappedValue: "update", key.rawValue)
    }
}
