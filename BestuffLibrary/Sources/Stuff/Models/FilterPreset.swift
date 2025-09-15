import Foundation

public struct FilterPreset: Codable, Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public var searchText: String
    public var dateFilter: String
    public var completion: String
    public var minScore: Int?
    public var labelName: String?

    public init(
        id: UUID = .init(),
        name: String,
        searchText: String,
        dateFilter: DateFilter,
        completion: CompletionFilter,
        minScore: Int?,
        labelName: String?
    ) {
        self.id = id
        self.name = name
        self.searchText = searchText
        self.dateFilter = dateFilter.rawValue
        self.completion = completion.rawValue
        self.minScore = minScore
        self.labelName = labelName
    }
}
