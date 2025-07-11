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

    @State private var isPresented = false

    var body: some View {
        Button("Edit Stuff", systemImage: "pencil") {
            Logger(#file).info("StuffFormButton tapped for edit")
            isPresented = true
        }
        .glassEffect()
        .sheet(isPresented: $isPresented) {
            StuffFormView()
                .environment(stuff)
        }
    }
}

#Preview(traits: .sampleData) {
    AddStuffButton()
}
