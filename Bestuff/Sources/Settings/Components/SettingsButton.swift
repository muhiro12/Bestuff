import SwiftUI

struct SettingsButton: View {
    var onTap: () -> Void = {}

    var body: some View {
        Button("Settings", systemImage: "gearshape") {
            Logger(#file).info("Settings button tapped")
            onTap()
        }
        .glassEffect()
    }
}

#Preview {
    SettingsButton {}
}
