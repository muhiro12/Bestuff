import AppIntents

enum PlanPeriod: String, CaseIterable, AppEnum {
    case nextMonth
    case nextYear

    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Plan Period"
    }

    nonisolated static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
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
