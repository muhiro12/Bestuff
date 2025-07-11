import SwiftUI

struct DebugButton: View {
    @State private var isPresented = false

    var body: some View {
        Button("Debug", systemImage: "ladybug") {
            Logger(#file).info("Debug button tapped")
            isPresented = true
        }
        .glassEffect()
        .sheet(isPresented: $isPresented) {
            DebugNavigationView()
        }
    }
}

#Preview {
    DebugButton()
}
