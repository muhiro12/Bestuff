//
//  ContentView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selection: Stuff?
    @State private var isRecapPresented = false
    @State private var isPlanPresented = false

    var body: some View {
        NavigationSplitView {
            StuffListView(selection: $selection)
        } detail: {
            if let stuff = selection {
                StuffView()
                    .environment(stuff)
            } else {
                Text("Select Stuff")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationDestination(for: Stuff.self) { stuff in
            StuffView()
                .environment(stuff)
        }
        .toolbar {

            ToolbarItem(placement: .primaryAction) {
                Button("Recap", systemImage: "calendar") {
                    Logger(#file).info("Recap button tapped")
                    isRecapPresented = true
                }
                .buttonStyle(.bordered)
                .liquidGlass()
            }

            ToolbarItem(placement: .primaryAction) {
                Button("Plan", systemImage: "lightbulb") {
                    Logger(#file).info("Plan button tapped")
                    isPlanPresented = true
                }
                .buttonStyle(.bordered)
                .liquidGlass()
            }
        }
        .sheet(isPresented: $isRecapPresented) {
            RecapTabView()
        }
        .sheet(isPresented: $isPlanPresented) {
            PlanTabView()
        }
    }
}

#Preview(traits: .sampleData) {
    ContentView()
}
