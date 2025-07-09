import AppIntents

enum PlanPeriod: String, CaseIterable, AppEnum {
    case nextMonth
    case nextYear

    static var typeDisplayName: LocalizedStringResource { "Plan Period" }

    static var caseDisplayRepresentations: [PlanPeriod: DisplayRepresentation] {
        [
            .nextMonth: .init(title: "Next Month"),
            .nextYear: .init(title: "Next Year")
        ]
    }
}

extension PlanPeriod {
    var title: String {
        switch self {
        case .nextMonth:
            "Next Month"
        case .nextYear:
            "Next Year"
        }
    }
}
