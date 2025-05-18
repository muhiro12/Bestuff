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

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var category: String = "General"
    @State private var score: Int = 0
    @State private var recommendLevel: Int = 3
    @State private var purchaseDate: Date = .now
    @State private var price: String = ""
    @State private var tags: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Menu {
                    ForEach(categoryOptions, id: \.self) { option in
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

                Section(header: Text("Tags")) {
                    TextField("Enter a tag", text: $currentTag)
                        .onSubmit {
                            addTag()
                        }

                    if !tagSuggestions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tagSuggestions.filter {
                                    $0.lowercased().hasPrefix(currentTag.lowercased()) && !tags.contains($0)
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

                    if !tags.isEmpty {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
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
                    RatingView(rating: $score)
                }

                Section(header: Text("Details")) {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)

                    VStack(alignment: .leading) {
                        Text("Recommend Level")
                        RatingView(rating: $recommendLevel)
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
                        item.update(
                            title: title,
                            score: score,
                            category: category,
                            note: note,
                            tags: tags,
                            imageData: item.imageData,
                            purchaseDate: purchaseDate,
                            price: Double(price),
                            recommendLevel: recommendLevel,
                            isPinned: item.isPinned
                        )
                        try? modelContext.save()
                        isPresented = nil
                    }
                    .tint(.accentColor)
                }
            }
            .onAppear {
                title = item.title
                note = item.note
                category = item.category
                score = item.score
                recommendLevel = item.recommendLevel
                purchaseDate = item.purchaseDate ?? .now
                price = item.price.map { String($0) } ?? ""
                tags = item.tags
            }
        }
    }

    private var tagSuggestions: [String] {
        var tagUsage: [String: Date] = [:]
        for item in allItems {
            for tag in item.tags {
                if let existing = tagUsage[tag] {
                    if item.createdTimestamp > existing {
                        tagUsage[tag] = item.createdTimestamp
                    }
                } else {
                    tagUsage[tag] = item.createdTimestamp
                }
            }
        }
        return tagUsage.sorted(by: { $0.value > $1.value }).map { $0.key }
    }

    private func addTag() {
        let trimmed = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        currentTag = ""
    }
}
