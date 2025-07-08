//
//  TagPickerView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct TagPickerView: View {
    let allTags: [String]
    @Binding var selectedTags: Set<String>
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    var filteredTags: [String] {
        if searchText.isEmpty {
            return allTags
        } else {
            return allTags.filter { $0.localizedStandardContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTags, id: \.self) { tag in
                    Toggle(isOn: Binding(
                        get: { selectedTags.contains(tag) },
                        set: { isOn in
                            if isOn {
                                selectedTags.insert(tag)
                            } else {
                                selectedTags.remove(tag)
                            }
                        }
                    )) {
                        Text(tag)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .searchable(text: $searchText)
            .navigationTitle("Select Tags")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        selectedTags.removeAll()
                        dismiss()
                    }
                }
            }
        }
        .appNavigationStyle()
        .appBackground()
    }
}
