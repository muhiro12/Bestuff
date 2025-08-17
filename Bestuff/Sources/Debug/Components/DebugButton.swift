import SwiftUI

struct DebugButton: View {
    var onTap: () -> Void = {}

    var body: some View {
        Button("Debug", systemImage: "ladybug") {
            Logger(#file).info("Debug button tapped")
            onTap()
        }
        .glassEffect()
    }
}

#Preview {
    DebugButton {}
}
