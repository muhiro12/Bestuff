import SwiftData

let testContext: ModelContext = {
    let schema = Schema([Stuff.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try! ModelContainer(for: schema, configurations: [configuration]).mainContext
}()
