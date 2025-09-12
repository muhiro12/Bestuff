//
//  AppIntent.swift
//  Widgets
//
//  Created by Hiromu Nakano on 2025/09/13.
//

import AppIntents
import WidgetKit

enum WidgetMode: String, AppEnum, CaseDisplayRepresentable, Sendable {
    case today
    case pinned
    case thisMonth

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Widget Mode")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .today: .init(stringLiteral: "Today"),
            .pinned: .init(stringLiteral: "Pinned"),
            .thisMonth: .init(stringLiteral: "This Month")
        ]
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Bestuff" }
    static var description: IntentDescription { "Show your Bestuff overview." }

    @Parameter(title: "Content")
    var mode: WidgetMode?
}
