//
//  BackupDocument.swift
//  Bestuff
//
//  Created by Codex on 2025/08/17.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let file = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        data = file
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        .init(regularFileWithContents: data)
    }
}
