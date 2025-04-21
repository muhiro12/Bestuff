//
//  CategoryAverageSectionView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct CategoryAverageSectionView: View {
    let items: [BestItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.vertical, 4)
            Text("Average Score per Category")
                .font(.headline)
                .padding(.bottom, 4)

            let grouped = Dictionary(grouping: items, by: { $0.category })
            let mapped = grouped.map { (category: $0.key, average: Double($0.value.map { $0.score }.reduce(0, +)) / Double($0.value.count)) }
            let averages = mapped.sorted(by: { $0.category < $1.category })

            ForEach(averages, id: \.category) { entry in
                Label("\(entry.category): \(String(format: "%.1f", entry.average))", systemImage: "chart.bar.xaxis")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous))
        .padding(.top)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}
