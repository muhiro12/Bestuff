import SwiftUI

struct ToTopButton: View {
    var action: () -> Void

    var body: some View {
        Button("To Top", systemImage: "chevron.up", action: action)
        .padding()
        .glassEffect()
    }
}

#Preview {
    ToTopButton {}
}
