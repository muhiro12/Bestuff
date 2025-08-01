//
//  BestuffApp.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import StoreKitWrapper
import SwiftData
import SwiftUI

@main
struct BestuffApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Stuff.self,
            Tag.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    private var sharedStore: Store = .init()
    private var sharedConfigurationService: ConfigurationService = .init()
    @AppStorage(BoolAppStorageKey.isDebugOn)
    private var isDebugOn

    init() {
        sharedStore.open(
            groupID: "group.com.example.bestuff",
            productIDs: ["com.example.bestuff.subscription"],
            purchasedSubscriptionsDidSet: nil
        )
#if DEBUG
        isDebugOn = true
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sharedStore)
                .environment(sharedConfigurationService)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            TextEditingCommands()
        }
    }
}
