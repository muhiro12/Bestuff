import SwiftData
import SwiftUI

struct PlanSuggestionView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var period: PlanPeriod = .nextMonth
    @State private var suggestions: PlanSuggestions?
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Period") {
                    Picker("Period", selection: $period) {
                        ForEach(PlanPeriod.allCases, id: \.self) { period in
                            Text(period.title)
                                .tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                if let suggestions {
                    Section("Suggestions") {
                        ForEach(suggestions.tasks, id: \.self) { task in
                            Text(task)
                        }
                    }
                }
            }
            .navigationTitle(Text("Plan"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Button("Generate") {
                            generate()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                    }
                }
            }
        }
    }

    private func generate() {
        isProcessing = true
        Task {
            suggestions = try? await SuggestPlanIntent.perform((context: modelContext, period: period))
            isProcessing = false
        }
    }
}

#Preview {
    PlanSuggestionView()
        .modelContainer(for: Stuff.self, inMemory: true)
}
