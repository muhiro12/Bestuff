//
//  BestuffApp.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import SwiftUI
import SwiftData

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

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            RecapView()
                .tabItem {
                    Label("Recap", systemImage: "star.circle")
                }
            BestItemListView()
                .tabItem {
                    Label("Items", systemImage: "list.bullet")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BestItem.self, configurations: config)
    let context = container.mainContext

    [
        BestItem(timestamp: .now, title: "Sample 1", score: 5, category: "Books"),
        BestItem(timestamp: .now, title: "Sample 2", score: 3, category: "Music"),
        BestItem(timestamp: .now, title: "Sample 3", score: 4, category: "Tech")
    ].forEach { context.insert($0) }

    return ContentView()
        .modelContainer(container)
}

import Foundation
import SwiftData

@Model
final class BestItem {
    var timestamp: Date
    var title: String
    var score: Int
    var category: String
    var note: String
    var tags: [String]

    init(timestamp: Date, title: String, score: Int, category: String = "General", note: String = "", tags: [String] = []) {
        self.timestamp = timestamp
        self.title = title
        self.score = score
        self.category = category
        self.note = note
        self.tags = tags
    }
}

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

struct BestItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bestItems: [BestItem]
    @State private var isPresentingAddSheet = false
    @State private var editingItem: BestItem? = nil
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .byDate
    @State private var minimumScore: Int = 1

    enum SortOption {
        case byDate, byScore
    }

    var filteredBestItems: [BestItem] {
        bestItems.filter { item in
            (item.title.localizedCaseInsensitiveContains(searchText) || item.category.localizedCaseInsensitiveContains(searchText)) && item.score >= minimumScore
        }
        .sorted(by: { (sortOption == .byDate) ? $0.timestamp < $1.timestamp : $0.score > $1.score })
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredBestItems.isEmpty {
                    Text("No items found.")
                        .foregroundColor(.gray)
                } else {
                    let flatItems = filteredBestItems
                    ForEach(Dictionary(grouping: flatItems, by: { $0.category }).sorted(by: { $0.key < $1.key }), id: \.key) { category, items in
                        Section(header: Text(category).foregroundColor(.accentColor)) {
                            ForEach(items) { item in
                                VStack(alignment: .leading, spacing: 6) {
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
            .navigationTitle("Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.accentColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(bestItems[index])
        }
    }
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var score: Int = 3
    @State private var category: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Category", text: $category)
            TextField("Note", text: $note, axis: .vertical)
                .lineLimit(3...5)

                Picker("Score", selection: $score) {
                    ForEach(1..<6) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.segmented)
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
                    let newItem = BestItem(timestamp: .now, title: title, score: score, category: category.isEmpty ? "General" : category, note: note)
                            modelContext.insert(newItem)
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

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("Settings View (Placeholder)")
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.accentColor, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct EditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: BestItem
    @Binding var isPresented: BestItem?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $item.title)
                TextField("Category", text: $item.category)
            TextField("Note", text: $item.note, axis: .vertical)
                .lineLimit(3...5)

                Picker("Score", selection: $item.score) {
                    ForEach(1..<6) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.segmented)
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
}

struct RecapView: View {
    @Query private var bestItems: [BestItem]
    @State private var isPresentingShareSheet = false
    @State private var sharedImage: UIImage?

    var body: some View {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let thisMonthBestItems = bestItems.filter {
            let itemMonth = calendar.component(.month, from: $0.timestamp)
            let itemYear = calendar.component(.year, from: $0.timestamp)
            return itemMonth == currentMonth && itemYear == currentYear
        }
        .sorted { $0.score > $1.score }

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("This Month's Best")
                        .font(.largeTitle.bold())
                        .padding(.bottom, 4)
                    Text("Your top-rated picks this month")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    recapContentView(for: thisMonthBestItems)
                        .padding()
                }
            }
            .navigationTitle("This Month's Recap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.accentColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        let renderer = ImageRenderer(content: recapContentView(for: thisMonthBestItems).padding())
                        renderer.scale = UIScreen.main.scale
                        if let uiImage = renderer.uiImage {
                            sharedImage = uiImage
                            isPresentingShareSheet = true
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresentingShareSheet) {
                if let image = sharedImage {
                    ShareSheet(activityItems: [image])
                }
            }
        }
    }

    @ViewBuilder
    private func recapContentView(for items: [BestItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                Text("No items added this month.")
            } else {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.category.uppercased())
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                        Text(item.title)
                            .font(AppFont.title)
                            .fontWeight(.semibold)
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
                    Divider()
                }
            }
        }
    }
}

import UIKit
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct CardViewModifier: ViewModifier {
    var background: LinearGradient

    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(DesignMetrics.shadowOpacity), radius: DesignMetrics.shadowRadius, x: 0, y: 2)
    }
}

extension View {
    func bestCardStyle(using gradient: LinearGradient) -> some View {
        self.modifier(CardViewModifier(background: gradient))
    }
}

import SwiftUI

enum AppFont {
    static let title = Font.title3.weight(.semibold)
    static let body = Font.subheadline
    static let caption = Font.caption2
}

enum AppColor {
    static let background = Color(.systemBackground)
    static let surface = Color(.secondarySystemBackground)
    static let accent = Color.accentColor
}

enum DesignMetrics {
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 4
    static let shadowOpacity: Double = 0.05
}
