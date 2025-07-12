//
//  ContentView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct ContentView: View {
    @Environment(ConfigurationService.self)
    private var configurationService
    @Environment(\.scenePhase)
    private var scenePhase

    @State private var isUpdateAlertPresented = false
    var body: some View {
        HomeTabBar()
            .alert(Text("Update Required"), isPresented: $isUpdateAlertPresented) {
                Button {
                    UIApplication.shared.open(
                        .init(string: "https://apps.apple.com/jp/app/incomes/id1584472982")!
                    )
                } label: {
                    Text("Open App Store")
                }
            } message: {
                Text("Please update Bestuff to the latest version to continue using it.")
            }
            .task {
                try? await configurationService.load()
                isUpdateAlertPresented = configurationService.isUpdateRequired()
            }
            .onChange(of: scenePhase) {
                guard scenePhase == .active else {
                    return
                }
                Task {
                    try? await configurationService.load()
                    isUpdateAlertPresented = configurationService.isUpdateRequired()
                }
            }
    }
}

#Preview(traits: .sampleData) {
    ContentView()
}
