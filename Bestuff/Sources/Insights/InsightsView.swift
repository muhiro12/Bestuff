//
//  InsightsView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query private var allItems: [BestItem]
    @State private var selectedCategory: String = "All"
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var pendingDeletion: BestItem? = nil
    @Environment(\.modelContext) private var modelContext

    var categoryCounts: [(category: String, count: Int)] {
        Dictionary(grouping: filteredItems, by: \.category)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    var scoreCounts: [(score: Int, count: Int)] {
        Dictionary(grouping: filteredItems, by: \.score)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.score < $1.score }
    }

    var monthlyCounts: [(month: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let grouped = Dictionary(grouping: filteredItems) { formatter.string(from: $0.createdTimestamp) }
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.month < $1.month }
    }

    var tagCounts: [(tag: String, count: Int)] {
        Dictionary(grouping: filteredItems.flatMap { $0.tags }, by: { $0 })
            .map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    private var filteredItems: [BestItem] {
        allItems.filter {
            (selectedCategory == "All" || $0.category == selectedCategory) &&
            Calendar.current.component(.year, from: $0.createdTimestamp) == selectedYear
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Picker("Category", selection: $selectedCategory) {
                                Text("All").tag("All")
                                ForEach(Array(Set(allItems.map(\.category))), id: \.self) {
                                    Text($0).tag($0)
                                }
                            }
                            .pickerStyle(.menu)

                            Picker("Year", selection: $selectedYear) {
                                ForEach((2020...Calendar.current.component(.year, from: Date())).reversed(), id: \.self) {
                                    Text("\($0)").tag($0)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    Text("Insights")
                        .font(.largeTitle.bold())
                    Text("Visualize trends and analyze your best items by category, score, and more.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    InsightsCard(title: "Items per Category") {
                        Chart {
                            ForEach(categoryCounts, id: \.category) { entry in
                                BarMark(
                                    x: .value("Items", entry.count),
                                    y: .value("Category", entry.category)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .cornerRadius(4)
                                .annotation(position: .trailing) {
                                    Text("\(entry.count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: CGFloat(categoryCounts.count * 40 + 40))
                    }
                    InsightsCard(title: "Top Items This Year") {
                        let calendar = Calendar.current
                        let year = calendar.component(.year, from: Date())

                        let topItemsThisYear = filteredItems.filter {
                            calendar.component(.year, from: $0.createdTimestamp) == year
                        }
                            .sorted { $0.score > $1.score }
                            .prefix(5)

                        Chart {
                            ForEach(Array(topItemsThisYear.enumerated()), id: \.1.createdTimestamp) { index, item in
                                BarMark(
                                    x: .value("Score", item.score),
                                    y: .value("Item", item.title)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .annotation(position: .trailing) {
                                    Text("\(item.score)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: 260)
                    }

                    InsightsCard(title: "Top Categories by Average Score") {
                        let categoryAverages = Dictionary(grouping: allItems, by: \.category)
                            .mapValues { items in
                                Double(items.map(\.score).reduce(0, +)) / Double(items.count)
                            }
                            .sorted { $0.value > $1.value }

                        Chart {
                            ForEach(categoryAverages.prefix(5), id: \.key) { category, average in
                                BarMark(
                                    x: .value("Average", average),
                                    y: .value("Category", category)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .cornerRadius(4)
                                .annotation(position: .trailing) {
                                    Text(String(format: "%.1f", average))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: CGFloat(min(categoryAverages.count, 5) * 30 + 40))
                    }

                    InsightsCard(title: "Score Distribution") {
                        Chart {
                            ForEach(scoreCounts, id: \.score) { entry in
                                BarMark(
                                    x: .value("Score", entry.score),
                                    y: .value("Count", entry.count)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .cornerRadius(4)
                                .annotation(position: .top) {
                                    Text("\(entry.count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 1))
                        }
                        .frame(height: 240)
                    }

                    InsightsCard(title: "Monthly Activity") {
                        Chart {
                            ForEach(monthlyCounts, id: \.month) { entry in
                                BarMark(
                                    x: .value("Month", entry.month),
                                    y: .value("Items", entry.count)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .cornerRadius(4)
                                .annotation(position: .top) {
                                    Text("\(entry.count)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                                AxisGridLine(); AxisTick(); AxisValueLabel()
                            }
                        }
                        .frame(height: 240)
                    }

                    InsightsCard(title: "Top Tags") {
                        Chart {
                            ForEach(tagCounts.prefix(10), id: \.tag) { entry in
                                BarMark(
                                    x: .value("Count", entry.count),
                                    y: .value("Tag", "#\(entry.tag)")
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .cornerRadius(4)
                                .annotation(position: .trailing) {
                                    Text("\(entry.count)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: CGFloat(min(tagCounts.count, 10) * 30 + 40))
                    }

                    InsightsCard(title: "Average Price by Category") {
                        let categoryAverages = Dictionary(grouping: allItems.filter { $0.price != nil }, by: \.category)
                            .mapValues { items in
                                items.compactMap(\.price).reduce(0, +) / Double(items.count)
                            }
                            .sorted { $0.value > $1.value }

                        Chart {
                            ForEach(categoryAverages.prefix(6), id: \.key) { category, avgPrice in
                                BarMark(
                                    x: .value("Average Price", avgPrice),
                                    y: .value("Category", category)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .cornerRadius(4)
                                .annotation(position: .trailing) {
                                    Text(String(format: "%.0f", avgPrice))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .frame(height: CGFloat(min(categoryAverages.count, 6) * 30 + 40))
                    }

                    InsightsCard(title: "Most Expensive Items") {
                        let expensiveItems = allItems.filter { $0.price != nil }
                            .sorted { ($0.price ?? 0) > ($1.price ?? 0) }
                            .prefix(5)
                        Chart {
                            ForEach(expensiveItems, id: \.createdTimestamp) { item in
                                BarMark(
                                    x: .value("Price", item.price ?? 0),
                                    y: .value("Item", item.title)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .annotation(position: .trailing) {
                                    Text(String(format: "%.0f", item.price ?? 0))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(position: .bottom)
                        }
                        .frame(height: 260)
                    }

                    InsightsCard(title: "Items per Recommend Level") {
                        let recommendLevelCounts = Dictionary(grouping: allItems, by: \.recommendLevel)
                            .map { ($0.key, $0.value.count) }
                            .sorted { $0.0 < $1.0 }

                        Chart {
                            ForEach(recommendLevelCounts, id: \.0) { level, count in
                                BarMark(
                                    x: .value("Recommend Level", level),
                                    y: .value("Count", count)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.8))
                                .cornerRadius(4)
                                .annotation(position: .top) {
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 1))
                        }
                        .frame(height: 240)
                    }
                }
                .padding(.horizontal)
                .padding()
            }

        }
        .alert(item: $pendingDeletion) { item in
            Alert(
                title: Text("Delete Item"),
                message: Text("Are you sure you want to delete \"\(item.title)\"?"),
                primaryButton: .destructive(Text("Delete")) {
                    withAnimation(.spring()) {
                        modelContext.delete(item)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
