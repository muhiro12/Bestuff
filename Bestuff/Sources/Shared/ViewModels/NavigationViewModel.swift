//
//  NavigationViewModel.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import Foundation

final class NavigationViewModel: ObservableObject {
    @Published var selectedItem: BestItemModel? = nil
    @Published var editingItem: BestItemModel? = nil
}
