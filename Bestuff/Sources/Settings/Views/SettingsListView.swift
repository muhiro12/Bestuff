//
//  SettingsListView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsListView: View {
    @AppStorage(BoolAppStorageKey.isSubscribeOn)
    private var isSubscribeOn
    @Environment(\.modelContext)
    private var modelContext

    @State private var isExporting = false
    @State private var exportDocument: BackupDocument?
    @State private var isImporting = false
    @State private var importErrorMessage: String?

    @AppStorage(StringAppStorageKey.backupImportStrategy)
    private var importStrategyRaw

    var body: some View {
        List {
            if !isSubscribeOn {
                NavigationLink {
                    StoreListView()
                } label: {
                    Text("Subscription")
                }
            }
            Section("General") {
                Label("Version 1.0.0", systemImage: "number")
            }
            Section("Support") {
                Link(
                    destination: URL(string: "mailto:support@example.com")!
                ) {
                    Label("Contact Support", systemImage: "envelope")
                }
                Link(
                    destination: URL(string: "https://example.com")!
                ) {
                    Label("Visit Website", systemImage: "safari")
                }
            }
            Section("Data") {
                Picker("Import Strategy", selection: $importStrategyRaw) {
                    Text("Skip duplicates").tag(BackupConflictStrategy.skip.rawValue)
                    Text("Update duplicates").tag(BackupConflictStrategy.update.rawValue)
                }
                Button("Export Backup", systemImage: "square.and.arrow.up.on.square") {
                    do {
                        let data = try BackupService.exportJSON(context: modelContext)
                        exportDocument = .init(data: data)
                        isExporting = true
                    } catch {
                        importErrorMessage = "Failed to export backup."
                    }
                }
                Button("Import Backup", systemImage: "square.and.arrow.down.on.square") {
                    isImporting = true
                }
                .tint(.accentColor)
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "BestuffBackup"
        ) { result in
            if case .failure = result {
                importErrorMessage = "Failed to write backup file."
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first,
                      let data = try? Data(contentsOf: url) else {
                    importErrorMessage = "Failed to read selected file."
                    return
                }
                do {
                    let strategy = BackupConflictStrategy(rawValue: importStrategyRaw) ?? .update
                    try BackupService.importJSON(context: modelContext, data: data, conflictStrategy: strategy)
                } catch {
                    importErrorMessage = "Failed to import backup."
                }
            case .failure:
                break
            }
        }
        .alert(importErrorMessage ?? "", isPresented: Binding(get: {
            importErrorMessage != nil
        }, set: { flag in
            if flag == false { importErrorMessage = nil }
        })) {
            Button("OK") {}
        }
    }
}

#Preview(traits: .sampleData) {
    SettingsListView()
}
