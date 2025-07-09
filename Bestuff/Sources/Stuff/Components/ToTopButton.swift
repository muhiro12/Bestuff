import SwiftUI

struct ToTopButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("To Top", systemImage: "chevron.up")
        }
        .padding()
        .glassEffect()
    }
}

#Preview {
    ToTopButton {}
}
