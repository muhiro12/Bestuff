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
    
    var bestItems: [BestItem] {
        allItems.filter {
            ($0.title.localizedStandardContains(searchText) || $0.category.localizedStandardContains(searchText)) &&
            $0.score >= minimumScore
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
                                            Haptic.impact()
                                            withAnimation(.spring()) {
                                                navigation.selectedItem = item
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
                                .contextMenu {
                                    Button {
                                        navigation.selectedItem = item
                                    } label: {
                                        Label("View Details", systemImage: "eye")
                                    }
                                    
                                    Button {
                                        navigation.editingItem = item
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                }
                                .onTapGesture {
                                    Haptic.impact()
                                    withAnimation(.spring()) {
                                        navigation.selectedItem = item
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                if let index = indexSet.first {
                                    pendingDeletion = items[index]
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
            .sheet(item: $navigation.editingItem) { item in
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
