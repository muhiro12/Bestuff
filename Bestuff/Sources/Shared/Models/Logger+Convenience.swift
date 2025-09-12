import Foundation
import OSLog

extension Logger {
    init(_ file: String) {
        self.init(
            subsystem: Bundle.main.bundleIdentifier!,
            category: file
        )
    }
}
