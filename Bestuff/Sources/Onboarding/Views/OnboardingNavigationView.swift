import SwiftData
import SwiftUI

struct OnboardingNavigationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage(BoolAppStorageKey.hasCompletedOnboarding) private var hasCompletedOnboarding

    @State private var page = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TabView(selection: $page) {
                    OnboardingPageView(
                        systemImage: "sparkles",
                        title: "Welcome to Bestuff",
                        message: "Capture things, add tags, and track progress."
                    )
                    .tag(0)

                    OnboardingPageView(
                        systemImage: "tag",
                        title: "Organize with Tags",
                        message: "Use Labels, Periods, and Resources to keep items tidy."
                    )
                    .tag(1)

                    OnboardingPageView(
                        systemImage: "square.and.arrow.up.on.square",
                        title: "Backup and Restore",
                        message: "Export your data or import backups from Settings."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                VStack(spacing: 12) {
                    Button(primaryTitle) {
                        nextOrFinish()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)

                    Button("Add Sample Data", systemImage: "doc.badge.plus") {
                        createSampleData()
                        finish()
                    }
                }
            }
            .padding()
            .navigationTitle("Getting Started")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { finish() }
                }
            }
        }
    }

    private var primaryTitle: String {
        page < 2 ? "Continue" : "Get Started"
    }

    private func nextOrFinish() {
        if page < 2 {
            page += 1
        } else {
            finish()
        }
    }

    private func finish() {
        hasCompletedOnboarding = true
        dismiss()
    }

    private func createSampleData() { SampleDataSeeder.seed(context: modelContext) }
}

private struct OnboardingPageView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(.accent)
            Text(title)
                .font(.title)
                .bold()
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

#Preview(traits: .sampleData) {
    OnboardingNavigationView()
}
