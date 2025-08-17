//
//  EditStuffButton.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI

struct EditStuffButton: View {
    @Environment(Stuff.self)
    private var stuff

    var onTap: () -> Void = {}

    var body: some View {
        Button("Edit Stuff", systemImage: "pencil") {
            Logger(#file).info("EditStuffButton tapped")
            onTap()
        }
        .glassEffect()
    }
}

#Preview(traits: .sampleData) {
    EditStuffButton {}
}
