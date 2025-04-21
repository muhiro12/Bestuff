//
//  RecapView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

struct RecapView: View {
    @Query private var bestItems: [BestItem]
    @State private var sharedImage: ShareImage?
    @StateObject private var navigation = NavigationViewModel()
    @State private var selectedDate: Date = Date()

    private var filteredItems: [BestItem] {
        let components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        return bestItems.filter {
            let itemComponents = Calendar.current.dateComponents([.year, .month], from: $0.timestamp)
            return itemComponents.year == components.year && itemComponents.month == components.month
        }
        .sorted { $0.score > $1.score }
    }

    private var totalCount: Int {
        filteredItems.count
    }

    private var totalScore: Int {
        filteredItems.map(\.score).reduce(0, +)
    }

    private var averageScore: Double {
        totalCount > 0 ? Double(totalScore) / Double(totalCount) : 0
    }

    var body: some View {
        return NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 12) {
                        DatePicker("Select Month", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(.horizontal)

                        if totalCount > 0 {
                            HStack(spacing: 16) {
                                Label("\(totalCount) items", systemImage: "square.stack.3d.up")
                                Label("Avg. \(String(format: "%.1f", averageScore))", systemImage: "chart.bar.xaxis")
                                Label("Total \(totalScore)", systemImage: "sum")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        }
                    }
                    recapContentView(for: filteredItems)
                        .padding()
                }
            }
            .navigationTitle("This Month's Recap")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        let shareContent = VStack(spacing: 12) {
                            HStack {
                                Image("AppIcon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text(DateFormatter.localizedString(from: selectedDate, dateStyle: .long, timeStyle: .none))
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)

                            recapContentView(for: filteredItems)
                                .padding()
                        }
                        let renderer = ImageRenderer(content: shareContent.padding())
                        renderer.scale = UIScreen.main.scale
                        if let uiImage = renderer.uiImage {
                            sharedImage = ShareImage(image: uiImage)
                        }
                    }
                }
            }
            .sheet(item: $sharedImage) { item in
                ShareSheet(activityItems: [item.image])
            }
            .navigationDestination(item: $navigation.selectedItem) { item in
                ItemDetailView(item: item)
            }
        }
        .sheet(item: $navigation.editingItem) { item in
            EditItemView(item: item, isPresented: $navigation.editingItem)
        }
    }

    private func recapContentView(for items: [BestItem]) -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                Text("No items added this month.")
            } else {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image("AppIcon") // Assuming "AppIcon" is in the asset catalog
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        Text(DateFormatter.localizedString(from: selectedDate, dateStyle: .long, timeStyle: .none))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                .padding(.bottom)

                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    ZStack(alignment: .topLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            if let data = item.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                    Text(item.category.prefix(1))
                                        .font(.largeTitle.bold())
                                        .foregroundColor(.white)
                                }
                                .frame(height: 200)
                            }
                            Text(item.category.uppercased())
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .clipShape(Capsule())
                            if index == 0 {
                                Text(item.title)
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.primary)
                            } else {
                                Text(item.title)
                                    .font(AppFont.title)
                                    .fontWeight(.semibold)
                            }
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
                                TagCapsuleView(tags: item.tags)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous)
                                .fill(Color.white.opacity(0.8))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        )
                        Text("#\(index + 1)")
                            .font(.headline)
                            .padding(6)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding(8)
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
                    Divider()
                }

                SummarySectionView(totalScore: totalScore, averageScore: averageScore, totalCount: totalCount)

                CategoryAverageSectionView(items: items)
                top5ItemsSection(for: items)
            }
        }
    }


    private func top5ItemsSection(for items: [BestItem]) -> some View {
        let topItems = items.sorted(by: { $0.score > $1.score }).prefix(5)
        return VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.vertical, 4)
            Text("Top 5 Items")
                .font(.headline)
                .padding(.bottom, 4)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(topItems.enumerated()), id: \.offset) { index, item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("#\(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(item.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Score: \(item.score)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

#Preview {
    RecapView()
        .modelContainer(for: BestItem.self)
}
