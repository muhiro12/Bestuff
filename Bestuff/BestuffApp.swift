//
//  BestuffApp.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - BestuffApp

@main
struct BestuffApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BestItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

@ViewBuilder
private func insightsCard<T: View>(title: String, @ViewBuilder content: () -> T) -> some View {
    VStack(alignment: .leading, spacing: 12) {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
        content()
    }
    .padding()
    .background(.thinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
}

// MARK: - InsightsView

struct InsightsView: View {
    @Query private var allItems: [BestItem]

    var categoryCounts: [(category: String, count: Int)] {
        Dictionary(grouping: allItems, by: \.category)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    var scoreCounts: [(score: Int, count: Int)] {
        Dictionary(grouping: allItems, by: \.score)
            .map { ($0.key, $0.value.count) }
            .sorted { $0.score < $1.score }
    }

    var monthlyCounts: [(month: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let grouped = Dictionary(grouping: allItems) { formatter.string(from: $0.timestamp) }
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.month < $1.month }
    }

    var tagCounts: [(tag: String, count: Int)] {
        Dictionary(grouping: allItems.flatMap { $0.tags }, by: { $0 })
            .map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Insights")
                        .font(.largeTitle.bold())
                    Text("Visualize trends and analyze your best items by category, score, and more.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    insightsCard(title: "Items per Category") {
                        Chart {
                            ForEach(categoryCounts, id: \.category) { entry in
                                BarMark(
                                    x: .value("Items", entry.count),
                                    y: .value("Category", entry.category)
                                )
                                .foregroundStyle(Gradient(colors: [Color.cyan.opacity(0.6), Color.accentColor]))
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
                    insightsCard(title: "Top Items This Year") {
                        let calendar = Calendar.current
                        let year = calendar.component(.year, from: Date())

                        let topItemsThisYear = allItems.filter {
                            calendar.component(.year, from: $0.timestamp) == year
                        }
                            .sorted { $0.score > $1.score }
                            .prefix(5)

                        Chart {
                            ForEach(Array(topItemsThisYear.enumerated()), id: \.1.timestamp) { index, item in
                                BarMark(
                                    x: .value("Score", item.score),
                                    y: .value("Item", item.title)
                                )
                                .foregroundStyle(Gradient(colors: [Color.cyan.opacity(0.6), Color.accentColor]))
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

                    insightsCard(title: "Top Categories by Average Score") {
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
                                .foregroundStyle(Gradient(colors: [Color.mint.opacity(0.6), Color.accentColor]))
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

                    insightsCard(title: "Score Distribution") {
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

                    insightsCard(title: "Monthly Activity") {
                        Chart {
                            ForEach(monthlyCounts, id: \.month) { entry in
                                BarMark(
                                    x: .value("Month", entry.month),
                                    y: .value("Items", entry.count)
                                )
                                .foregroundStyle(Color.accentColor.opacity(0.7))
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

                    insightsCard(title: "Top Tags") {
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

                    insightsCard(title: "Average Price by Category") {
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

                    insightsCard(title: "Most Expensive Items") {
                        let expensiveItems = allItems.filter { $0.price != nil }
                            .sorted { ($0.price ?? 0) > ($1.price ?? 0) }
                            .prefix(5)
                        Chart {
                            ForEach(expensiveItems, id: \.timestamp) { item in
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

                    insightsCard(title: "Items per Recommend Level") {
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
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            BestItemListView()
                .tabItem {
                    Label("Items", systemImage: "list.bullet")
                }
                .tag(0)
            RecapView()
                .tabItem {
                    Label("Recap", systemImage: "star.circle")
                }
                .tag(1)
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BestItem.self, configurations: config)
    let context = container.mainContext

    BestItem.create(context: context, title: "AirPods Pro", score: 5, category: "Tech", note: "Great for daily use", tags: ["audio", "Apple"])
    BestItem.create(context: context, title: "The Alchemist", score: 4, category: "Books", note: "Inspiring story", tags: ["novel", "life"])
    BestItem.create(context: context, title: "Uniqlo Jacket", score: 3, category: "Fashion", note: "Affordable and warm", tags: ["winter", "clothing"])
    BestItem.create(context: context, title: "Sushi Lunch", score: 5, category: "Food", note: "Fresh and delicious", tags: ["restaurant", "lunch"])
    BestItem.create(context: context, title: "Spotify Premium", score: 4, category: "Music", note: "Good variety of playlists", tags: ["subscription", "music"])

    return ContentView()
        .modelContainer(container)
}

// MARK: - BestItem Model

@Model
final class BestItem {
    var timestamp: Date = Date.now
    var title: String = ""
    var score: Int = 0
    var category: String = "General"
    var note: String = ""
    var tags: [String] = []
    var imageData: Data? = nil
    var purchaseDate: Date? = nil
    var price: Double? = nil
    var recommendLevel: Int = 3

    private init() {}

    @discardableResult
    static func create(
        context: ModelContext,
        title: String,
        score: Int,
        category: String = "General",
        note: String = "",
        tags: [String] = [],
        purchaseDate: Date? = nil,
        price: Double? = nil,
        recommendLevel: Int = 3
    ) -> BestItem {
        let item = BestItem()
        item.timestamp = .now
        item.title = title
        item.score = score
        item.category = category
        item.note = note
        item.tags = tags
        item.purchaseDate = purchaseDate
        item.price = price
        item.recommendLevel = recommendLevel
        context.insert(item)
        return item
    }
}

// MARK: - BestItem Gradient Extension

extension BestItem {
    var gradient: LinearGradient {
        let base = Double(score) / 5.0
        return LinearGradient(
            colors: [
                Color.cyan.opacity(0.3 + base * 0.2),
                Color.accentColor.opacity(0.4 + base * 0.4)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - BestItemListView

struct BestItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [BestItem]

    var bestItems: [BestItem] {
        allItems.filter {
            ($0.title.localizedStandardContains(searchText) || $0.category.localizedStandardContains(searchText)) &&
            $0.score >= minimumScore
        }
    }
    @State private var isPresentingAddSheet = false
    @State private var editingItem: BestItem? = nil
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .byDate
    @State private var minimumScore: Int = 1

    enum SortOption {
        case byDate, byScore
    }


    var body: some View {
        NavigationStack {
        List {
            Section {
                Text("Track and reflect on your favorite purchases. Use filters above to customize the view.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            let sortedItems = bestItems.sorted { (sortOption == .byDate) ? $0.timestamp < $1.timestamp : $0.score > $1.score }
                if sortedItems.isEmpty {
                    if allItems.isEmpty {
                        Section {
                            VStack(alignment: .center, spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 40))
                                    .foregroundColor(.accentColor)
                                Text("Start tracking your favorites!")
                                    .font(.headline)
                                Text("Tap the + button to add your first Best Item.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    } else {
                        Section {
                            VStack(alignment: .center, spacing: 12) {
                                Text("No matching items found.")
                                    .font(.headline)
                                if searchText.isEmpty {
                                    Text("Here are some of your recent top-rated items:")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    let recentItems = allItems
                                        .sorted(by: { $0.timestamp > $1.timestamp })
                                        .prefix(3)

                                    ForEach(recentItems) { item in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.title)
                                                .font(AppFont.title)
                                            Text("Score: \(item.score)")
                                                .font(AppFont.body)
                                                .foregroundStyle(.secondary)
                                        }
                                        .bestCardStyle(using: item.gradient)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                editingItem = item
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    }
                } else {
                    let flatItems = sortedItems
                    ForEach(Dictionary(grouping: flatItems, by: { $0.category }).sorted(by: { $0.key < $1.key }), id: \.key) { category, items in
                        Section(header: Text(category).foregroundColor(.accentColor)) {
                            ForEach(items) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    if let data = item.imageData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 140)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                    Text(item.category.uppercased())
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.accentColor.opacity(0.15))
                                        .clipShape(Capsule())
                                    Text(item.title)
                                        .font(AppFont.title)
                                    Text("Score: \(item.score)")
                                        .font(AppFont.body)
                                        .foregroundStyle(.secondary)
                                    Text(item.timestamp.formatted(date: .abbreviated, time: .omitted))
                                        .font(AppFont.caption)
                                        .foregroundStyle(.gray)
                                    if !item.note.isEmpty {
                                        Text(item.note)
                                            .font(AppFont.body)
                                            .foregroundStyle(.primary)
                                            .padding(.top, 4)
                                    }
                                    if !item.tags.isEmpty {
                                        HStack {
                                            ForEach(item.tags, id: \.self) { tag in
                                                Text("#\(tag)")
                                                    .font(.caption2)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(Color.accentColor.opacity(0.1))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                                .bestCardStyle(using: item.gradient)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        editingItem = item
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                withAnimation(.spring()) {
                                    for index in indexSet {
                                        let item = items[index]
                                        modelContext.delete(item)
                                    }
                                }
                            }
                        }
                    }
                }
        }
        .navigationTitle("Your Best Picks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAddSheet = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Min Score", selection: $minimumScore) {
                        ForEach(1..<6) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("Sort", selection: $sortOption) {
                        Text("Date").tag(SortOption.byDate)
                        Text("Score").tag(SortOption.byScore)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .sheet(isPresented: $isPresentingAddSheet) {
                AddItemView(isPresented: $isPresentingAddSheet)
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item, isPresented: $editingItem)
            }
        }
    }

}

// MARK: - AddItemView

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var score: Int = 3
    @State private var category: String = ""
    @State private var note: String = ""
    @State private var purchaseDate: Date = .now
    @State private var price: String = ""
    @State private var recommendLevel: Int = 3

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Menu {
                    ForEach(["Books", "Music", "Tech", "Fashion", "Food", "Other"], id: \.self) { option in
                        Button(option) {
                            category = option
                        }
                    }
                } label: {
                    HStack {
                        Text(category.isEmpty ? "Select Category" : category)
                            .foregroundColor(category.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
                TextField("Note", text: $note, axis: .vertical)
                    .lineLimit(3...5)

                Section(header: Text("Rating")) {
                    RatingView(rating: $score, maxRating: 100, step: 20)
                }

                Section(header: Text("Details")) {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)

                    VStack(alignment: .leading) {
                        Text("Recommend Level")
                        RatingView(rating: $recommendLevel, maxRating: 100, step: 20)
                    }
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        withAnimation(.spring()) {
                            _ = BestItem.create(
                                context: modelContext,
                                title: title,
                                score: score,
                                category: category.isEmpty ? "General" : category,
                                note: note,
                                tags: [],
                                purchaseDate: purchaseDate,
                                price: Double(price),
                                recommendLevel: recommendLevel
                            )
                        }
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                    .tint(.accentColor)
                }
            }
        }
    }
}


// MARK: - SettingsView

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown")", systemImage: "number")
                }
                // TODO: Replace this placeholder with actual subscription functionality
                Section(header: Text("Subscription")) {
                    Label("Rate us on the App Store", systemImage: "star")
                }
                // TODO: Replace this placeholder with actual license list view
                Section(header: Text("Licenses")) {
                    Label("Open Source Licenses", systemImage: "doc.plaintext")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - EditItemView

struct EditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: BestItem
    @Binding var isPresented: BestItem?
    let categoryOptions = ["Books", "Music", "Tech", "Fashion", "Food", "Other"]
    @Query private var allItems: [BestItem]
    @State private var currentTag: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $item.title)
                Menu {
                    ForEach(categoryOptions, id: \.self) { option in
                        Button(option) {
                            item.category = option
                        }
                    }
                } label: {
                    HStack {
                        Text(item.category.isEmpty ? "Select Category" : item.category)
                            .foregroundColor(item.category.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
                TextField("Note", text: $item.note, axis: .vertical)
                    .lineLimit(3...5)

                Section(header: Text("Tags")) {
                    TextField("Enter a tag", text: $currentTag)
                        .onSubmit {
                            addTag()
                        }

                    if !tagSuggestions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tagSuggestions.filter {
                                    $0.lowercased().hasPrefix(currentTag.lowercased()) && !item.tags.contains($0)
                                }, id: \.self) { suggestion in
                                    Button(action: {
                                        currentTag = suggestion
                                        addTag()
                                    }) {
                                        Text("#\(suggestion)")
                                            .font(.caption)
                                            .padding(6)
                                            .background(Color.accentColor.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }

                    if !item.tags.isEmpty {
                        HStack {
                            ForEach(item.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.accentColor.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 4)
                    }
                }

                Section(header: Text("Rating")) {
                    RatingView(rating: $item.score)
                }

                Section(header: Text("Details")) {
                    DatePicker("Purchase Date", selection:
                                Binding(
                                    get: { item.purchaseDate ?? .now },
                                    set: { item.purchaseDate = $0 }
                                ),
                               displayedComponents: .date
                    )
                    TextField("Price", text: Binding(
                        get: {
                            if let price = item.price {
                                let formatter = NumberFormatter()
                                formatter.numberStyle = .currency
                                formatter.locale = Locale.current
                                return formatter.string(from: NSNumber(value: price)) ?? ""
                            } else {
                                return ""
                            }
                        },
                        set: {
                            let sanitized = $0.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                            item.price = Double(sanitized)
                        }
                    ))
                    .keyboardType(.decimalPad)

                    VStack(alignment: .leading) {
                        Text("Recommend Level")
                        RatingView(rating: $item.recommendLevel)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? modelContext.save()
                        isPresented = nil
                    }
                    .tint(.accentColor)
                }
            }
        }
    }

    private var tagSuggestions: [String] {
        Array(Set(allItems.flatMap { $0.tags })).sorted()
    }

    private func addTag() {
        let trimmed = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && !item.tags.contains(trimmed) else { return }
        item.tags.append(trimmed)
        currentTag = ""
    }
}

// MARK: - RecapView

struct RecapView: View {
    @Query private var bestItems: [BestItem]
    @State private var sharedImage: ShareImage?
    @State private var editingItem: BestItem? = nil
    @State private var selectedDate: Date = Date()

    private var filteredItems: [BestItem] {
        let components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        return bestItems.filter {
            let itemComponents = Calendar.current.dateComponents([.year, .month], from: $0.timestamp)
            return itemComponents.year == components.year && itemComponents.month == components.month
        }
        .sorted { $0.score > $1.score }
    }

    private var totalCount: Int {
        filteredItems.count
    }

    private var totalScore: Int {
        filteredItems.map(\.score).reduce(0, +)
    }

    private var averageScore: Double {
        totalCount > 0 ? Double(totalScore) / Double(totalCount) : 0
    }

    var body: some View {
        return NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        DatePicker("Select Month", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(.horizontal)

                        if totalCount > 0 {
                            HStack(spacing: 16) {
                                Label("\(totalCount) items", systemImage: "square.stack.3d.up")
                                Label("Avg. \(String(format: "%.1f", averageScore))", systemImage: "chart.bar.xaxis")
                                Label("Total \(totalScore)", systemImage: "sum")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        }
                    }
                    recapContentView(for: filteredItems)
                        .padding()
                }
            }
            .navigationTitle("This Month's Recap")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        let renderer = ImageRenderer(content: recapContentView(for: filteredItems).padding())
                        renderer.scale = UIScreen.main.scale
                        if let uiImage = renderer.uiImage {
                            sharedImage = ShareImage(image: uiImage)
                        }
                    }
                }
            }
            .sheet(item: $sharedImage) { item in
                ShareSheet(activityItems: [item.image])
            }
        }
        .sheet(item: $editingItem) { item in
            EditItemView(item: item, isPresented: $editingItem)
        }
    }

    private func recapContentView(for items: [BestItem]) -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                Text("No items added this month.")
            } else {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    ZStack(alignment: .topLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            if let data = item.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                    Text(item.category.prefix(1))
                                        .font(.largeTitle.bold())
                                        .foregroundColor(.white)
                                }
                                .frame(height: 200)
                            }
                            Text(item.category.uppercased())
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .clipShape(Capsule())
                            if index == 0 {
                                Text(item.title)
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.primary)
                            } else {
                                Text(item.title)
                                    .font(AppFont.title)
                                    .fontWeight(.semibold)
                            }
                            Text("Score: \(item.score)")
                                .font(AppFont.body)
                                .foregroundStyle(.secondary)
                            Text(item.timestamp.formatted(date: .abbreviated, time: .omitted))
                                .font(AppFont.caption)
                                .foregroundStyle(.gray)
                            if !item.note.isEmpty {
                                Text(item.note)
                                    .font(AppFont.body)
                                    .foregroundStyle(.primary)
                                    .padding(.top, 4)
                            }
                            if !item.tags.isEmpty {
                                HStack {
                                    ForEach(item.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.caption2)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(Color.accentColor.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        )
                        Text("#\(index + 1)")
                            .font(.headline)
                            .padding(6)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding(8)
                    }
                    .bestCardStyle(using: item.gradient)
                    .onTapGesture {
                        self.editingItem = item
                    }
                    Divider()
                }
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    Text("Summary")
                        .font(.headline)
                        .padding(.bottom, 4)

                    Label("Total Score: \(totalScore)", systemImage: "sum")
                    Label("Average Score: \(String(format: "%.1f", averageScore))", systemImage: "chart.bar.xaxis")
                    Label("Total Items: \(totalCount)", systemImage: "square.stack.3d.up")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous))
                .padding(.top)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - ShareImage
final class ShareImage: Identifiable {
    let id = UUID()
    let image: UIImage

    init(image: UIImage) {
        self.image = image
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - CardViewModifier

struct CardViewModifier: ViewModifier {
    var background: LinearGradient
    var isTopItem: Bool = false

    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(isTopItem ? 0.1 : DesignMetrics.shadowOpacity),
                    radius: isTopItem ? 10 : DesignMetrics.shadowRadius,
                    x: 0, y: isTopItem ? 4 : 2)
    }
}

extension View {
    func bestCardStyle(using gradient: LinearGradient, isTopItem: Bool = false) -> some View {
        self.modifier(CardViewModifier(background: gradient, isTopItem: isTopItem))
    }
}

// MARK: - Style Definitions

enum AppFont {
    static let title = Font.title3.weight(.semibold)
    static let body = Font.subheadline
    static let caption = Font.caption2
}
enum DesignMetrics {
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 4
    static let shadowOpacity: Double = 0.05
}

// MARK: - RatingView

struct RatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 100
    var step: Int = 20

    var body: some View {
        HStack(spacing: 8) {
            let segments = maxRating / step
            ForEach(0...segments, id: \.self) { i in
                let level = i * step
                Image(systemName: level <= rating ? "circle.fill" : "circle")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        rating = level
                    }
            }
        }
        .padding(.vertical, 4)
    }
}
