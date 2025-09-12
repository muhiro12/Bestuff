//
//  Widgets.swift
//  Widgets
//
//  Created by Hiromu Nakano on 2025/09/13.
//

import BestuffLibrary
import SwiftData
import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in _: Context) -> Entry {
        .init(date: .now, mode: .today, summary: .placeholder)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) -> Entry {
        let mode = configuration.mode ?? .today
        let summary = WidgetData.summary(mode: mode)
        return .init(date: .now, mode: mode, summary: summary)
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) -> Timeline<Entry> {
        let mode = configuration.mode ?? .today
        let summary = WidgetData.summary(mode: mode)
        let entry = Entry(date: .now, mode: mode, summary: summary)
        // Refresh every 30 minutes
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1_800)
        return Timeline(entries: [entry], policy: .after(next))
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let mode: WidgetMode
    let summary: WidgetSummary
}

struct WidgetsEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        switch entry.mode {
        case .today:
            TodayView(summary: entry.summary)
        case .pinned:
            PinnedView(summary: entry.summary)
        case .thisMonth:
            MonthView(summary: entry.summary)
        }
    }
}

struct Widgets: Widget {
    let kind: String = "Widgets"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WidgetsEntryView(entry: entry)
                .padding(8)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

// MARK: - Views

private struct TodayView: View {
    let summary: WidgetSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Today", systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Pending")
                Spacer()
                Text("\(summary.todayPending)")
                    .font(.title)
                    .bold()
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Done")
                Spacer()
                Text("\(summary.todayDone)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.secondary)
            }
            if let latest = summary.latestTitle {
                Divider()
                Text(latest)
                    .font(.footnote)
                    .lineLimit(2)
            }
        }
    }
}

private struct PinnedView: View {
    let summary: WidgetSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Pinned", systemImage: "pin")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(summary.pinnedTitle ?? "No pinned items")
                .font(.headline)
                .lineLimit(3)
        }
    }
}

private struct MonthView: View {
    let summary: WidgetSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("This Month", systemImage: "chart.bar")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                VStack(alignment: .leading) {
                    Text("Items")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(summary.monthCount)")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Completed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(summary.monthDone)")
                        .font(.title3)
                        .bold()
                }
            }
        }
    }
}

// MARK: - Data

struct WidgetSummary: Sendable {
    let todayPending: Int
    let todayDone: Int
    let latestTitle: String?
    let pinnedTitle: String?
    let monthCount: Int
    let monthDone: Int

    static let placeholder = Self(
        todayPending: 3,
        todayDone: 1,
        latestTitle: "Morning Run",
        pinnedTitle: "Read 'Atomic Habits'",
        monthCount: 12,
        monthDone: 5
    )
}

enum WidgetData {
    // For simplicity, create a transient container. In production, use an App Group.
    private static var container: ModelContainer = {
        let schema = Schema([Stuff.self, Tag.self])
        return try! ModelContainer(for: schema)
    }()

    static func summary(mode _: WidgetMode) -> WidgetSummary {
        let context = container.mainContext
        let now = Date()

        // Today
        let todays: [Stuff] = (try? StuffService.stuffs(context: context, sameDayAs: now)) ?? []
        let pending = todays.filter { $0.isCompleted == false }.count
        let done = todays.filter(\.isCompleted).count
        let latest = todays.sorted { $0.occurredAt > $1.occurredAt }.first?.title

        // Pinned
        let pinned = (try? context.fetch(FetchDescriptor<Stuff>()))?.first(where: \.isPinned)?.title

        // Month
        let months: [Stuff] = (try? StuffService.stuffs(context: context, monthOf: now)) ?? []
        let monthDone = months.filter(\.isCompleted).count

        return WidgetSummary(
            todayPending: pending,
            todayDone: done,
            latestTitle: latest,
            pinnedTitle: pinned,
            monthCount: months.count,
            monthDone: monthDone
        )
    }
}

#Preview(as: .systemSmall) {
    Widgets()
} timeline: {
    Entry(date: .now, mode: .today, summary: .placeholder)
    Entry(date: .now, mode: .pinned, summary: .placeholder)
    Entry(date: .now, mode: .thisMonth, summary: .placeholder)
}
