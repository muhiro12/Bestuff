import SwiftUI

struct SettingsButton: View {
    @State private var isPresented = false

    var body: some View {
        Button("Settings", systemImage: "gearshape") {
            Logger(#file).info("Settings button tapped")
            isPresented = true
        }
        .glassEffect()
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                SettingsListView()
            }
        }
    }
}

#Preview {
    SettingsButton()
}
