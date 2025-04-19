//
//  Item.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/19.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
