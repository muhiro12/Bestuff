//
//  AddStuffButton.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct AddStuffButton: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Add Item", systemImage: "plus")
        }
        .sheet(isPresented: $isPresented) {
            StuffFormView()
        }
    }
}

#Preview {
    AddStuffButton()
        .modelContainer(for: Stuff.self, inMemory: true)
}

