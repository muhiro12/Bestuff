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
        Button("Add Stuff", systemImage: "plus") {
            Logger(#file).info("AddStuffButton tapped")
            isPresented = true
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
