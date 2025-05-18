//
//  TagCapsuleView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct TagCapsuleView: View {
    let tags: [String]
    let onDelete: ((String) -> Void)?

    var body: some View {
        HStack {
            ForEach(tags, id: \.self) { tag in
                HStack(spacing: 4) {
                    Text("#\(tag)")
                        .font(.caption2)
                    if let onDelete {
                        Button {
                            onDelete(tag)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(Capsule())
            }
        }
    }
}
