//
//  AddItemView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import PhotosUI
import SwiftData

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
    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @Query private var allItems: [BestItemModel]
    @State private var currentTag: String = ""
    @State private var tags: [String] = []

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

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                PhotosPicker(selection: $selectedImageItem, matching: .images) {
                    Label("Add Image", systemImage: "photo")
                }
                .onChange(of: selectedImageItem) {
                    Task {
                        if let data = try? await selectedImageItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
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

                Section(header: Text("Tags")) {
                    TextField("Enter a tag", text: $currentTag)
                        .onSubmit {
                            let trimmed = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty && !tags.contains(trimmed) else { return }
                            tags.append(trimmed)
                            currentTag = ""
                        }

                    if !tagSuggestions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tagSuggestions.filter {
                                    $0.lowercased().hasPrefix(currentTag.lowercased()) && !tags.contains($0)
                                }, id: \.self) { suggestion in
                                    Button(action: {
                                        currentTag = suggestion
                                        let trimmed = currentTag.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard !trimmed.isEmpty && !tags.contains(trimmed) else { return }
                                        tags.append(trimmed)
                                        currentTag = ""
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
                        TagCapsuleView(tags: tags, onDelete: { tag in
                            tags.removeAll { $0 == tag }
                        })
                            .padding(.top, 4)
                    }
                }

                Section(header: Text("Rating")) {
                    RatingView(rating: $score, maxRating: 100)
                }

                Section(header: Text("Details")) {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)

                    VStack(alignment: .leading) {
                        Text("Recommend Level")
                        RatingView(rating: $recommendLevel, maxRating: 100)
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
                            do {
                                _ = try CreateBestItemIntent.perform(
                                    title: title,
                                    score: score,
                                    category: category.isEmpty ? "General" : category,
                                    note: note,
                                    tags: tags,
                                    imageData: selectedImageData,
                                    purchaseDate: purchaseDate,
                                    price: Double(price),
                                    recommendLevel: recommendLevel
                                )
                            } catch {
                                assertionFailure()
                            }
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
