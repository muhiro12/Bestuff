import SwiftData
import SwiftUI

struct SuggestPlanButton: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Plan", systemImage: "lightbulb")
        }
        .glassEffect()
        .sheet(isPresented: $isPresented) {
            PlanSuggestionView()
        }
    }
}

#Preview {
    SuggestPlanButton()
        .modelContainer(for: Stuff.self, inMemory: true)
}
