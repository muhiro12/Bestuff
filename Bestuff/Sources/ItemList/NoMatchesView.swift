//
//  NoMatchesView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct NoMatchesView: View {
    let allItems: [BestItem]
    let searchText: String
    @ObservedObject var navigation: NavigationViewModel

    var body: some View {
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
}
