//
//  DebugNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI

struct DebugNavigationView: View {
    var body: some View {
        NavigationStack {
            DebugListView()
        }
    }
}

#Preview {
    DebugNavigationView()
}
