//
//  RatingView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 100
    // Removed step parameter as it's no longer needed

    var body: some View {
        Picker("Rating", selection: $rating) {
            ForEach(0...maxRating, id: \.self) { value in
                Text("\(value)")
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 120)
    }
}
