//
//  BestItemListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

struct BestItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [BestItem]

    @State private var selectedMonth: Date? = nil
    @State private var selectedCategory: String? = nil
    @State private var selectedTags: Set<String> = []

    var bestItems: [BestItem] {
        allItems.filter {
            ($0.title.localizedStandardContains(searchText) || $0.category.localizedStandardContains(searchText)) &&
            $0.score >= minimumScore &&
            (selectedMonth == nil || Calendar.current.isDate($0.timestamp, equalTo: selectedMonth!, toGranularity: .month)) &&
            (selectedCategory == nil || $0.category == selectedCategory) &&
            selectedTags.allSatisfy { $0.isEmpty || $0 == "" || $0 == "All" }
        }
    }

    @State private var isPresentingAddSheet = false
    @StateObject private var navigation = NavigationViewModel()
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .byDate
    @State private var minimumScore: Int = 1
    @State private var pendingDeletion: BestItem? = nil

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
                        EmptyPlaceholderView()
                    } else {
                        NoMatchesView(allItems: allItems, searchText: searchText, navigation: navigation)
                    }
                } else {
                    let flatItems = sortedItems
                    ForEach(Dictionary(grouping: flatItems, by: { $0.category }).sorted(by: { $0.key < $1.key }), id: \.key) { category, items in
                        BestItemSectionView(category: category, items: items, navigation: navigation, pendingDeletion: $pendingDeletion)
                    }
                }
            }
            .navigationTitle("Your Best Picks")
            .toolbar {
                BestItemListToolbar(
                    isPresentingAddSheet: $isPresentingAddSheet,
                    minimumScore: $minimumScore,
                    sortOption: $sortOption,
                    selectedMonth: $selectedMonth,
                    selectedCategory: $selectedCategory,
                    selectedTags: $selectedTags,
                    allItems: allItems
                )
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .sheet(isPresented: $isPresentingAddSheet) {
                AddItemView(isPresented: $isPresentingAddSheet)
            }
            .sheet(item: $navigation.editingItem, onDismiss: {
                searchText += ""
            }) { item in
                EditItemView(item: item, isPresented: $navigation.editingItem)
            }
            .navigationDestination(item: $navigation.selectedItem) { item in
                ItemDetailView(item: item)
            }
        }
    }

}

#Preview {
    BestItemListView()
        .modelContainer(for: BestItem.self)
}
