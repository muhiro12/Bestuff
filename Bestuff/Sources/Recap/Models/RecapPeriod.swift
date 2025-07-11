//
//  RecapPeriod.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import Foundation

enum RecapPeriod: String, CaseIterable, Identifiable {
    case monthly
    case yearly

    var id: Self { self }

    var title: String {
        switch self {
        case .monthly:
            "Monthly"
        case .yearly:
            "Yearly"
        }
    }
}
