//
//  SummarySectionView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct SummarySectionView: View {
    let totalScore: Int
    let averageScore: Double
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.vertical, 4)
            Text("Summary")
                .font(.headline)
                .padding(.bottom, 4)

            Label("Total Score: \(totalScore)", systemImage: "sum")
            Label("Average Score: \(String(format: "%.1f", averageScore))", systemImage: "chart.bar.xaxis")
            Label("Total Items: \(totalCount)", systemImage: "square.stack.3d.up")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignMetrics.cornerRadius, style: .continuous))
        .padding(.top)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}
