//
//  DebugNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI
import SwiftUtilities

struct DebugNavigationView: View {
    var body: some View {
        NavigationStack {
            DebugListView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        CloseButton()
                    }
                }
        }
    }
}

#Preview {
    DebugNavigationView()
}
