//
//  SettingsListView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/09.
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

struct SettingsListView: View {
    @AppStorage(BoolAppStorageKey.isSubscribeOn)
    private var isSubscribeOn
    @Environment(\.modelContext)
    private var modelContext

    @State private var isExporting = false
    @State private var exportDocument: BackupDocument?
    @State private var isImporting = false
    @State private var importErrorMessage: String?
    @State private var successMessage: String?
    @State private var pendingExportCounts: (tags: Int, stuffs: Int)?

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
                Label(appVersionLabel, systemImage: "number")
            }
            Section("Support") {
                Link(
                    destination: supportMailURL ?? URL(string: "mailto:support@example.com")!
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
                        // Precompute counts to show after successful export
                        let tagCount = try contextTagCount()
                        let stuffCount = try contextStuffCount()
                        pendingExportCounts = (tags: tagCount, stuffs: stuffCount)
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
            defaultFilename: defaultBackupFilename
        ) { result in
            switch result {
            case .success:
                if let counts = pendingExportCounts {
                    successMessage = "Exported backup (\(counts.tags) tags, \(counts.stuffs) items)."
                } else {
                    successMessage = "Backup exported successfully."
                }
                pendingExportCounts = nil
            case .failure:
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
                    // Decode payload to report counts
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    if let payload = try? decoder.decode(BackupPayload.self, from: data) {
                        let tagCount = payload.tags.count
                        let stuffCount = payload.stuffs.count
                        let strategy = BackupConflictStrategy(rawValue: importStrategyRaw) ?? .update
                        try BackupService.importJSON(context: modelContext, data: data, conflictStrategy: strategy)
                        successMessage = "Imported backup (\(tagCount) tags, \(stuffCount) items)."
                    } else {
                        let strategy = BackupConflictStrategy(rawValue: importStrategyRaw) ?? .update
                        try BackupService.importJSON(context: modelContext, data: data, conflictStrategy: strategy)
                        successMessage = "Backup imported successfully."
                    }
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
        .alert(successMessage ?? "", isPresented: Binding(get: {
            successMessage != nil
        }, set: { flag in
            if flag == false { successMessage = nil }
        })) {
            Button("OK") {}
        }
    }
}

#Preview(traits: .sampleData) {
    SettingsListView()
}

private extension SettingsListView {
    var supportMailURL: URL? {
        let to = "support@example.com"
        var subject = "Bestuff Support Request"
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            subject = "\(appName) Support Request"
        }
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let osInfo: String = {
            #if canImport(UIKit)
            let device = UIDevice.current
            return "\(device.systemName) \(device.systemVersion)"
            #elseif canImport(AppKit)
            return ProcessInfo.processInfo.operatingSystemVersionString
            #else
            return "Unknown OS"
            #endif
        }()
        let header = "Please describe your issue here.\n\n---"
        let meta = "App: \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Bestuff") \(version) (Build \(build))\nOS: \(osInfo)"
        let body = "\(header)\n\(meta)\n"
        func encode(_ s: String) -> String {
            s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
        }
        let urlString = "mailto:\(to)?subject=\(encode(subject))&body=\(encode(body))"
        return URL(string: urlString)
    }

    func contextTagCount() throws -> Int {
        try modelContext.fetch(FetchDescriptor<Tag>()).count
    }

    func contextStuffCount() throws -> Int {
        try modelContext.fetch(FetchDescriptor<Stuff>()).count
    }

    var appVersionLabel: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String
        let build = info?["CFBundleVersion"] as? String
        switch (version, build) {
        case let (.some(v), .some(b)):
            return "Version \(v) (Build \(b))"
        case let (.some(v), nil):
            return "Version \(v)"
        case let (nil, .some(b)):
            return "Build \(b)"
        default:
            return "Version"
        }
    }

    var defaultBackupFilename: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let stamp = formatter.string(from: Date())
        return "BestuffBackup-\(stamp)"
    }
}
