//
//  BestItemListToolbar.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct BestItemListToolbar: ToolbarContent {
    @Binding var isPresentingAddSheet: Bool
    @Binding var minimumScore: Int
    @Binding var sortOption: BestItemListView.SortOption
    @Binding var selectedMonth: Date?
    @Binding var selectedCategory: String?
    @Binding var selectedTags: Set<String>
    @Binding var isPresentingTagPicker: Bool
    var allItems: [BestItemModel]

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Haptic.impact()
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
                Text("Date").tag(BestItemListView.SortOption.byDate)
                Text("Score").tag(BestItemListView.SortOption.byScore)
            }
            .pickerStyle(.segmented)
        }
        ToolbarItem(placement: .bottomBar) {
            DatePicker("Month", selection: Binding(
                get: { selectedMonth ?? Date() },
                set: { newDate in selectedMonth = newDate }
            ), displayedComponents: [.date])
            .labelsHidden()
            .datePickerStyle(.compact)
        }
        ToolbarItem(placement: .bottomBar) {
            if selectedMonth != nil {
                Button {
                    selectedMonth = nil
                } label: {
                    Label("Clear Month", systemImage: "xmark.circle")
                }
            }
        }
        ToolbarItem(placement: .bottomBar) {
            Menu {
                Button("All Categories") {
                    selectedCategory = nil
                }
                ForEach(Array(Set(allItems.map(\.category))).sorted(), id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                    }
                }
            } label: {
                Label("Category", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
        ToolbarItem(placement: .bottomBar) {
            Button {
                isPresentingTagPicker = true
            } label: {
                Label("Tags", systemImage: "tag.circle")
            }
        }
    }
}
