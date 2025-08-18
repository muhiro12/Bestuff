import SwiftUI

enum BoolAppStorageKey: String {
    case isSubscribeOn = "a018f613"
    case isDebugOn = "a1B2c3D4"
    case hasCompletedOnboarding = "onboarding_completed"
}

extension AppStorage where Value == Bool {
    init(_ key: BoolAppStorageKey) {
        self.init(wrappedValue: false, key.rawValue)
    }
}

enum StringAppStorageKey: String {
    case backupImportStrategy = "bKp_ImportStrategy"
    case tagSearchText = "tag_search_text"
    case tagFilterType = "tag_filter_type"
    case savedFilters = "saved_filters_v1"
}

extension AppStorage where Value == String {
    init(_ key: StringAppStorageKey) {
        let defaultValue: String
        switch key {
        case .backupImportStrategy:
            defaultValue = "update"
        case .tagSearchText:
            defaultValue = ""
        case .tagFilterType:
            defaultValue = "all"
        case .savedFilters:
            defaultValue = "[]"
        }
        self.init(wrappedValue: defaultValue, key.rawValue)
    }
}
