//
//  BestItemSectionView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct BestItemSectionView: View {
    let category: String
    let items: [BestItem]
    @ObservedObject var navigation: NavigationViewModel
    @Binding var pendingDeletion: BestItem?

    var body: some View {
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
