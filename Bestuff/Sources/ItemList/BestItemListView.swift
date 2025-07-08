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
    @Query private var allItems: [BestItemModel]

    @State private var selectedMonth: Date? = nil
    @State private var selectedCategory: String? = nil
    @State private var selectedTags: Set<String> = []
    @State private var isPresentingTagPicker: Bool = false

    var bestItems: [BestItemModel] {
        allItems.filter {
            ($0.title.localizedStandardContains(searchText) || $0.category.localizedStandardContains(searchText)) &&
            $0.score >= minimumScore &&
            (selectedMonth == nil || Calendar.current.isDate($0.createdTimestamp, equalTo: selectedMonth!, toGranularity: .month)) &&
            (selectedCategory == nil || $0.category == selectedCategory) &&
            (selectedTags.isEmpty || selectedTags.isSubset(of: Set($0.tags)))
        }
    }

    @State private var isPresentingAddSheet = false
    @StateObject private var navigation = NavigationViewModel()
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .byDate
    @State private var minimumScore: Int = 1
    @State private var pendingDeletion: BestItemModel? = nil

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
                let sortedItems = bestItems.sorted {
                    if $0.isPinned != $1.isPinned {
                        return $0.isPinned && !$1.isPinned
                    }
                    return (sortOption == .byDate) ? $0.createdTimestamp < $1.createdTimestamp : $0.score > $1.score
                }
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
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Your Best Picks")
            .toolbar {
                BestItemListToolbar(
                    isPresentingAddSheet: $isPresentingAddSheet,
                    minimumScore: $minimumScore,
                    sortOption: $sortOption,
                    selectedMonth: $selectedMonth,
                    selectedCategory: $selectedCategory,
                    selectedTags: $selectedTags,
                    isPresentingTagPicker: $isPresentingTagPicker,
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
            .sheet(isPresented: $isPresentingTagPicker) {
                TagPickerView(
                    allTags: Array(Set(allItems.flatMap(\.tags))).sorted(),
                    selectedTags: $selectedTags
                )
            }
            .navigationDestination(item: $navigation.selectedItem) { item in
                ItemDetailView(item: item)
            }
        }
        .appNavigationStyle()
        .appBackground()
    }
}

#Preview {
    BestItemListView()
        .modelContainer(for: BestItemModel.self)
}
