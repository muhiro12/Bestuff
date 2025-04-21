//
//  AddItemView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import PhotosUI

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
                            _ = BestItem.create(
                                context: modelContext,
                                title: title,
                                score: score,
                                category: category.isEmpty ? "General" : category,
                                note: note,
                                tags: [],
                                imageData: selectedImageData,
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
