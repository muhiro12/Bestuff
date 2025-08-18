import Foundation

struct FilterPreset: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var searchText: String
    var dateFilter: String
    var completion: String
    var minScore: Int?
    var labelName: String?

    init(
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
