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
            Item.self,
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
            ItemListView()
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
    let container = try! ModelContainer(for: Item.self, configurations: config)
    let context = container.mainContext

    [
        Item(timestamp: .now, title: "Sample 1", score: 5, category: "Books"),
        Item(timestamp: .now, title: "Sample 2", score: 3, category: "Music"),
        Item(timestamp: .now, title: "Sample 3", score: 4, category: "Tech")
    ].forEach { context.insert($0) }

    return ContentView()
        .modelContainer(container)
}

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var title: String
    var score: Int
    var category: String

    init(timestamp: Date, title: String, score: Int, category: String = "General") {
        self.timestamp = timestamp
        self.title = title
        self.score = score
        self.category = category
    }
}

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var isPresentingAddSheet = false
    @State private var editingItem: Item? = nil
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .byDate
    @State private var minimumScore: Int = 1

    enum SortOption {
        case byDate, byScore
    }

    var filteredItems: [Item] {
        items.filter { item in
            (item.title.localizedCaseInsensitiveContains(searchText) || item.category.localizedCaseInsensitiveContains(searchText)) && item.score >= minimumScore
        }
        .sorted(by: { (sortOption == .byDate) ? $0.timestamp < $1.timestamp : $0.score > $1.score })
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredItems.isEmpty {
                    Text("No items found.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(Dictionary(grouping: filteredItems, by: { $0.category }).sorted(by: { $0.key < $1.key }), id: \.key) { category, items in
                        Section(header: Text(category)) {
                            ForEach(items) { item in
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.headline)
                                    Text("Score: \(item.score)")
                                        .font(.subheadline)
                                    Text(item.timestamp.formatted())
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .onTapGesture {
                                    editingItem = item
                                }
                            }
                            .onDelete(perform: deleteItems)
                        }
                    }
                }
            }
            .navigationTitle("Items")
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
            modelContext.delete(items[index])
        }
    }
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var score: Int = 3
    @State private var category: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Category", text: $category)

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
                        let newItem = Item(timestamp: .now, title: title, score: score, category: category)
                        modelContext.insert(newItem)
                        isPresented = false
                    }
                    // TODO: Consider validating category input or using a picker to standardize categories.
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            // TODO: Implement meaningful settings options before release (e.g., version info, feedback, etc.)
            Text("Settings View (Placeholder)")
                .navigationTitle("Settings")
        }
    }
}

struct EditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: Item
    @Binding var isPresented: Item?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $item.title)
                TextField("Category", text: $item.category)

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
                        isPresented = nil
                    }
                }
            }
        }
    }
}

struct RecapView: View {
    @Query private var items: [Item]
    @State private var isPresentingShareSheet = false
    @State private var sharedImage: UIImage?

    var body: some View {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        let thisMonthItems = items.filter {
            let itemMonth = calendar.component(.month, from: $0.timestamp)
            let itemYear = calendar.component(.year, from: $0.timestamp)
            return itemMonth == currentMonth && itemYear == currentYear
        }
        .sorted { $0.score > $1.score }

        NavigationStack {
            ScrollView {
                recapContent(thisMonthItems)
                    .padding()
            }
            .navigationTitle("This Month's Recap")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        let renderer = ImageRenderer(content: recapContent(thisMonthItems).padding())
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
    private func recapContent(_ items: [Item]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                Text("No items added this month.")
                    .foregroundColor(.gray)
            } else {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        Text("Score: \(item.score)")
                            .font(.subheadline)
                        Text(item.timestamp.formatted())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
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
