import SwiftUI

struct AddTagButton: View {
    @State private var isPresented = false

    var body: some View {
        Button("Add Tag", systemImage: "plus") {
            Logger(#file).info("TagFormButton tapped for new")
            isPresented = true
        }
        .glassEffect()
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                TagFormView()
            }
        }
    }
}

#Preview(traits: .sampleData) {
    AddTagButton()
}
