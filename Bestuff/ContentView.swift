//
//  ContentView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        StuffListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Stuff.self, inMemory: true)
}
