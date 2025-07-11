//
//  AddStuffButton.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct AddStuffButton: View {
    var body: some View {
        StuffFormButton(title: "Add Stuff", systemImage: "plus")
            .glassEffect()
    }
}

#Preview(traits: .sampleData) {
    AddStuffButton()
}
