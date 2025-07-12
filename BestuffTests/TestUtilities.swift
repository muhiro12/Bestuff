@testable import Bestuff
import SwiftData

var testContext: ModelContext {
    let schema = Schema([Stuff.self, Tag.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return .init(
        try! .init(for: schema, configurations: [configuration])
    )
}
