import AppIntents
import SwiftData

enum TagTypeIntent: String, AppEnum {
    case label
    case period
    case resource

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Tag Type")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .label: .init(stringLiteral: "Label"),
            .period: .init(stringLiteral: "Period"),
            .resource: .init(stringLiteral: "Resource")
        ]
    }

    var modelType: TagType {
        switch self {
        case .label: .label
        case .period: .period
        case .resource: .resource
        }
    }
}

@MainActor
struct GetStuffsByTagIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource { "Get Stuffs By Tag" }

    @Parameter(title: "Tag Name")
    private var name: String

    @Parameter(title: "Tag Type")
    private var type: TagTypeIntent

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<[StuffEntity]> {
        let tag = try Tag.fetch(byName: name, type: type.modelType, in: modelContainer.mainContext)
        let models = tag?.stuffs ?? []
        return .result(value: models.compactMap(StuffEntity.init))
    }
}
