//
//  NavigationViewModel.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import Foundation

final class NavigationViewModel: ObservableObject {
    @Published var selectedItem: BestItem? = nil
    @Published var editingItem: BestItem? = nil
}
