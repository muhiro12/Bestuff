//
//  RecapPeriod.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import Foundation

public enum RecapPeriod: String, CaseIterable, Identifiable {
    case monthly
    case yearly

    public var id: Self { self }

    public var title: String {
        switch self {
        case .monthly:
            "Monthly"
        case .yearly:
            "Yearly"
        }
    }
}
