//
//  Stuff.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import Foundation
import SwiftData

@Model
final class Stuff {
    var title: String
    var category: String
    var note: String?
    var createdAt: Date

    init(title: String, category: String, note: String? = nil, createdAt: Date = .now) {
        self.title = title
        self.category = category
        self.note = note
        self.createdAt = createdAt
    }
}

