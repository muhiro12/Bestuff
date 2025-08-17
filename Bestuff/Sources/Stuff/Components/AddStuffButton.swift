//
//  AddStuffButton.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct AddStuffButton: View {
    var onTap: () -> Void = {}

    var body: some View {
        Button("Add Stuff", systemImage: "plus") {
            Logger(#file).info("AddStuffButton tapped")
            onTap()
        }
        .glassEffect()
    }
}

#Preview(traits: .sampleData) {
    AddStuffButton {}
}
