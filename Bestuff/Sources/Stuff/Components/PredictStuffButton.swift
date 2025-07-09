import SwiftData
import SwiftUI

struct PredictStuffButton: View {
    @State private var isPresented = false

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Predict Stuff", systemImage: "wand.and.stars")
        }
        .glassEffect()
        .sheet(isPresented: $isPresented) {
            PredictStuffFormView()
        }
    }
}

#Preview {
    PredictStuffButton()
        .modelContainer(for: Stuff.self, inMemory: true)
}
