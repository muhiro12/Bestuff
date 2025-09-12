//
//  ConfigurationService.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import Foundation
import Observation

@Observable
@MainActor
public final class ConfigurationService {
    public private(set) var configuration: Configuration?

    private let decoder = JSONDecoder()

    public init() {}

    public func load() async throws {
        let data = try await URLSession.shared.data(
            from: .init(
                string: "https://raw.githubusercontent.com/muhiro12/Bestuff/main/.config.json"
            )!
        ).0
        configuration = try decoder.decode(Configuration.self, from: data)
    }

    public func isUpdateRequired() -> Bool {
        guard let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let required = configuration?.requiredVersion,
              Bundle.main.bundleIdentifier?.contains("playgrounds") == false else {
            return false
        }
        return current.compare(required, options: .numeric) == .orderedAscending
    }
}
