//
//  StuffDetailView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct StuffDetailView: View {
    @Environment(Stuff.self)
    private var stuff

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(stuff.title)
                    .font(.title)
                Text(stuff.category)
                    .font(.headline)
                if let note = stuff.note {
                    Text(note)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(Text(stuff.title))
        .toolbar {
            ShareLink(item: description)
        }
    }

    private var description: String {
        [stuff.title, stuff.category, stuff.note].compactMap(\.self).joined(separator: "\n")
    }
}

#Preview {
    NavigationStack {
        StuffDetailView()
            .environment(Stuff(title: "Sample", category: "General", note: "Notes"))
    }
}
