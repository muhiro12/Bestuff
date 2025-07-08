//
//  Item.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
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
