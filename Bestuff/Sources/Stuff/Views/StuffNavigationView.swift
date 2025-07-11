//
//  StuffNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI
import SwiftUtilities

struct StuffNavigationView: View {
    @State private var selection: Stuff?
    @State private var searchText = ""
    @State private var sort: StuffSort = .occurredDateDescending
    @State private var isRecapPresented = false
    @State private var isPlanPresented = false
    @State private var isSettingsPresented = false
    @State private var isDebugPresented = false
    @State private var isEditing = false

    var body: some View {
        NavigationSplitView {
            StuffListView(
                selection: $selection,
                searchText: $searchText,
                sort: $sort
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    AddStuffButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Picker("Sort", selection: $sort) {
                            ForEach(StuffSort.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("Recap", systemImage: "calendar") {
                        Logger(#file).info("Recap button tapped")
                        isRecapPresented = true
                    }
                    .buttonStyle(.bordered)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("Plan", systemImage: "lightbulb") {
                        Logger(#file).info("Plan button tapped")
                        isPlanPresented = true
                    }
                    .buttonStyle(.bordered)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("Settings", systemImage: "gearshape") {
                        Logger(#file).info("Settings button tapped")
                        isSettingsPresented = true
                    }
                }
                #if DEBUG
                ToolbarItem(placement: .secondaryAction) {
                    Button("Debug", systemImage: "ladybug") {
                        Logger(#file).info("Debug button tapped")
                        isDebugPresented = true
                    }
                }
                #endif
            }
        } detail: {
            if let stuff = selection {
                StuffView()
                    .environment(stuff)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            ShareLink(
                                item: [
                                    stuff.title,
                                    stuff.category,
                                    "Score: \(stuff.score)",
                                    stuff.note
                                ].compactMap(\.self).joined(separator: "\n")
                            )
                        }
                        ToolbarItem(placement: .primaryAction) {
                            Button("Edit", systemImage: "pencil") {
                                isEditing = true
                            }
                            .buttonStyle(.borderedProminent)
                            .sheet(isPresented: $isEditing) {
                                StuffFormView(stuff: stuff)
                            }
                        }
                    }
            } else {
                Text("Select Stuff")
                    .foregroundStyle(.secondary)
            }
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $isRecapPresented) {
            RecapNavigationView()
        }
        .sheet(isPresented: $isPlanPresented) {
            PlanNavigationView()
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsNavigationView()
        }
        .sheet(isPresented: $isDebugPresented) {
            DebugNavigationView()
        }
    }
}

#Preview(traits: .sampleData) {
    StuffNavigationView()
}
