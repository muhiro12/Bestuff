//
//  SettingsNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI

struct SettingsNavigationView: View {
    var body: some View {
        NavigationStack {
            SettingsListView()
        }
    }
}

#Preview {
    SettingsNavigationView()
}
