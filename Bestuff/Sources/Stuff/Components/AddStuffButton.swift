//
//  AddStuffButton.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct AddStuffButton: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            Logger(#file).info("AddStuffButton tapped")
            isPresented = true
        } label: {
            Label("Add Stuff", systemImage: "plus")
        }
        .glassEffect()
        .sheet(isPresented: $isPresented) {
            StuffFormView()
        }
    }
}

#Preview(traits: .sampleData) {
    AddStuffButton()
}
