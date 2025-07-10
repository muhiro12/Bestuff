import SwiftData
import SwiftUI

struct PredictStuffButton: View {
    @State private var isPresented = false

    var body: some View {
        Button("Predict Stuff", systemImage: "wand.and.stars") {
            Logger(#file).info("PredictStuffButton tapped")
            isPresented = true
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
