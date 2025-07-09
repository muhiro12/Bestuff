@testable import Bestuff
import SwiftData

let testContext: ModelContext = {
    let schema = Schema([Stuff.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return .init(
        try! .init(for: schema, configurations: [configuration])
    )
}()
