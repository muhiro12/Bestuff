//
//  StuffFormButton.swift
//  Bestuff
//
//  Created by Codex on 2025/07/11.
//

import SwiftUI

struct StuffFormButton<Label: View>: View {
    var stuff: Stuff?
    private let label: () -> Label
    @State private var isPresented = false

    init(
        stuff: Stuff? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.stuff = stuff
        self.label = label
    }

    var body: some View {
        Button(action: present) {
            label()
        }
        .sheet(isPresented: $isPresented) {
            StuffFormView(stuff: stuff)
        }
    }

    private func present() {
        Logger(#file).info(
            "StuffFormButton tapped" + (stuff == nil ? " for new" : " for edit")
        )
        isPresented = true
    }
}

extension StuffFormButton where Label == Label<Text> {
    init(
        stuff: Stuff? = nil,
        title: String,
        systemImage: String
    ) {
        self.init(stuff: stuff) {
            Label(title, systemImage: systemImage)
        }
    }
}

#Preview(traits: .sampleData) {
    StuffFormButton(title: "Add Stuff", systemImage: "plus")
}
