//
//  ContentView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            BestItemListView()
                .tabItem {
                    Label("Items", systemImage: "list.bullet")
                }
                .tag(0)
            RecapView()
                .tabItem {
                    Label("Recap", systemImage: "star.circle")
                }
                .tag(1)
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .appBackground()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BestItemModel.self, configurations: config)
    let context = container.mainContext

    _ = try! CreateBestItemIntent.perform(title: "AirPods Pro", score: 5, category: "Tech", note: "Great for daily use", tags: ["audio", "Apple"])
    _ = try! CreateBestItemIntent.perform(title: "The Alchemist", score: 4, category: "Books", note: "Inspiring story", tags: ["novel", "life"])
    _ = try! CreateBestItemIntent.perform(title: "Uniqlo Jacket", score: 3, category: "Fashion", note: "Affordable and warm", tags: ["winter", "clothing"])
    _ = try! CreateBestItemIntent.perform(title: "Sushi Lunch", score: 5, category: "Food", note: "Fresh and delicious", tags: ["restaurant", "lunch"])
    _ = try! CreateBestItemIntent.perform(title: "Spotify Premium", score: 4, category: "Music", note: "Good variety of playlists", tags: ["subscription", "music"])

    return ContentView()
        .modelContainer(container)
}
