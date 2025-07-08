//
//  StuffDetailView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct StuffDetailView: View {
    let stuff: Stuff

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
        [stuff.title, stuff.category, stuff.note].compactMap { $0 }.joined(separator: "\n")
    }
}

#Preview {
    NavigationStack {
        StuffDetailView(stuff: .init(title: "Sample", category: "General", note: "Notes"))
    }
}

