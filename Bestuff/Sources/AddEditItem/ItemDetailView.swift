//
//  ItemDetailView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct ItemDetailView: View {
    let item: BestItem
    @State private var editingItem: BestItem? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let data = item.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                }
                Text(item.title)
                    .font(.title)
                    .fontWeight(.bold)
                HStack {
                    Text(item.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Score: \(item.score)")
                        .font(.subheadline)
                }
                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.body)
                }
                if !item.tags.isEmpty {
                    HStack {
                        ForEach(item.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(4)
                                .background(Color.accentColor.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
                if let price = item.price {
                    Text("Price: \(price, specifier: "%.2f")")
                        .font(.body)
                }
                if let purchaseDate = item.purchaseDate {
                    Text("Purchased on: \(purchaseDate, formatter: dateFormatter)")
                        .font(.body)
                }
                Text("Recommend Level: \(item.recommendLevel)")
                    .font(.body)
            }
            .padding()
        }
        .appBackground()
        .navigationTitle("Item Details")
        .appNavigationStyle()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    editingItem = item
                }
            }
        }
        // Confirmed: The only usage of EditItemView in the project is here within ItemDetailView’s .sheet.
        .sheet(item: $editingItem) { item in
            EditItemView(item: item, isPresented: $editingItem)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
