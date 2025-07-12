import SwiftUI

struct HomeTabBar: View {
    var body: some View {
        TabView {
            StuffNavigationView()
                .tabItem {
                    Label("Stuff", systemImage: "list.bullet")
                }
            TagNavigationView()
                .tabItem {
                    Label("Tags", systemImage: "tag")
                }
        }
    }
}

#Preview(traits: .sampleData) {
    HomeTabBar()
}
