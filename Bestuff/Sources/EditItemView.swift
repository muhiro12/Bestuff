//
//  EditItemView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

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
        var tagUsage: [String: Date] = [:]
        for item in allItems {
            for tag in item.tags {
                if let existing = tagUsage[tag] {
                    if item.timestamp > existing {
                        tagUsage[tag] = item.timestamp
                    }
                } else {
                    tagUsage[tag] = item.timestamp
                }
            }
        }
        return tagUsage.sorted(by: { $0.value > $1.value }).map { $0.key }
    }

    private func addTag() {
        let trimmed = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && !item.tags.contains(trimmed) else { return }
        item.tags.append(trimmed)
        currentTag = ""
    }
}
