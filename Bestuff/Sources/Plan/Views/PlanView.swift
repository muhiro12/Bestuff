//
//  PlanView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/30.
//

import EventKit
import SwiftData
import SwiftUI

struct PlanView: View {
    let selection: PlanSelection

    @State private var isShowingExportSheet = false
    @State private var isShowingEventEditor = false
    @State private var isShowingReminderEditor = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var preparedEvent: EKEvent?
    @State private var reminderDueDate: Date = .now
    @State private var shouldExpandSteps = false
    @Environment(\.modelContext)
    private var modelContext
    @State private var savedStuff: Stuff?
    @State private var isShowingSavedSheet = false

    var body: some View {
        List {
            Section("Overview") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(selection.item.title)
                        .font(.headline)
                    Text(selection.item.rationale)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 12) {
                    Label("\(selection.item.estimatedMinutes) min", systemImage: "clock")
                    Label("Priority \(selection.item.priority)", systemImage: "flag")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            if !selection.item.steps.isEmpty {
                Section("Steps") {
                    ForEach(Array(selection.item.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(step)
                        }
                    }
                }
            }

            if !selection.item.resources.isEmpty {
                Section("Resources") {
                    ForEach(selection.item.resources, id: \.self) { resource in
                        Text(resource)
                    }
                }
            }

            if !selection.item.risks.isEmpty {
                Section("Risks") {
                    ForEach(selection.item.risks, id: \.self) { risk in
                        Text(risk)
                    }
                }
            }

            if !selection.item.successCriteria.isEmpty {
                Section("Success Criteria") {
                    ForEach(selection.item.successCriteria, id: \.self) { criterion in
                        Text(criterion)
                    }
                }
            }
        }
        .navigationTitle("Suggestion")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Menu("Export", systemImage: "square.and.arrow.down") {
                    Button("Add to Calendar…", systemImage: "calendar") {
                        presentEventEditor()
                    }
                    Button("Add to Reminders…", systemImage: "checklist") {
                        presentReminderEditor()
                    }
                    Divider()
                    Button("Save as Stuff", systemImage: "tray.and.arrow.down") {
                        saveAsStuff()
                    }
                }
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text(alertMessage))
        }
        #if canImport(EventKitUI)
        .sheet(isPresented: $isShowingEventEditor) {
            if let event = preparedEvent {
                EKEventEditView(store: EventKitService.shared.eventStore, event: event) { result in
                    switch result {
                    case .saved(let id):
                        alertMessage = "Calendar event saved (id: \(id ?? "n/a"))"
                    case .deleted:
                        alertMessage = "Calendar event deleted"
                    case .canceled:
                        alertMessage = "Canceled"
                    }
                    isShowingEventEditor = false
                    isShowingAlert = true
                }
            }
        }
        #endif
        .sheet(isPresented: $isShowingReminderEditor) {
            NavigationStack {
                Form {
                    Section("Due Date") {
                        DatePicker("Due", selection: $reminderDueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    Section("Options") {
                        Toggle("Create step reminders", isOn: $shouldExpandSteps)
                    }
                    if !selection.item.steps.isEmpty {
                        Section("Steps Preview") {
                            ForEach(selection.item.steps, id: \.self) { step in
                                Text(step)
                            }
                        }
                    }
                }
                .navigationTitle("Add to Reminders")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isShowingReminderEditor = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            exportToReminders(dueDate: reminderDueDate, expandSteps: shouldExpandSteps)
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isShowingSavedSheet) {
            if let savedStuff {
                NavigationStack {
                    StuffView()
                        .environment(savedStuff)
                }
            }
        }
    }

    private func presentEventEditor() {
        Task {
            do {
                let event = try await EventKitService.shared.prepareEvent(
                    title: selection.item.title,
                    notes: selection.item.rationale,
                    durationMinutes: selection.item.estimatedMinutes,
                    period: selection.period,
                    priority: selection.item.priority
                )
                preparedEvent = event
                isShowingEventEditor = true
            } catch {
                alertMessage = "Failed to prepare calendar event"
                isShowingAlert = true
            }
        }
    }

    private func presentReminderEditor() {
        reminderDueDate = EventKitService.shared.defaultStartDate(for: selection.period)
        // デフォルトはステップ数が6以下なら展開
        shouldExpandSteps = selection.item.steps.count <= 6
        isShowingReminderEditor = true
    }

    private func exportToReminders(dueDate: Date, expandSteps: Bool) {
        Task {
            do {
                let id = try await EventKitService.shared.addReminder(
                    title: selection.item.title,
                    notes: selection.item.rationale,
                    dueDate: dueDate,
                    steps: selection.item.steps,
                    expandSteps: expandSteps,
                    priority: selection.item.priority
                )
                alertMessage = "Reminder saved (id: \(id))"
                isShowingAlert = true
            } catch {
                alertMessage = "Failed to save reminder"
                isShowingAlert = true
            }
        }
    }

    private func saveAsStuff() {
        Task {
            do {
                let occurredAt = EventKitService.shared.defaultStartDate(for: selection.period)
                let title = selection.item.title

                var noteLines: [String] = []
                if !selection.item.rationale.isEmpty {
                    noteLines.append("Rationale: \(selection.item.rationale)")
                }
                if !selection.item.steps.isEmpty {
                    noteLines.append("Steps:")
                    for (index, step) in selection.item.steps.enumerated() {
                        noteLines.append("\(index + 1). \(step)")
                    }
                }
                if !selection.item.resources.isEmpty {
                    noteLines.append("Resources: \(selection.item.resources.joined(separator: ", "))")
                }
                if !selection.item.successCriteria.isEmpty {
                    noteLines.append("Success: \(selection.item.successCriteria.joined(separator: ", "))")
                }
                let note = noteLines.isEmpty ? nil : noteLines.joined(separator: "\n")

                var tagModels: [Tag] = []
                tagModels.append(Tag.findOrCreate(name: selection.period.title, in: modelContext))
                for resource in selection.item.resources.prefix(5) {
                    let trimmed = resource.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { continue }
                    tagModels.append(Tag.findOrCreate(name: trimmed, in: modelContext))
                }

                  let model = try StuffService.create(
                      context: modelContext,
                      title: title,
                      note: note,
                      occurredAt: occurredAt,
                      tags: tagModels
                  )
                model.update(source: "plan:\(selection.period.rawValue)")
                alertMessage = "Saved as Stuff"
                isShowingAlert = true
                savedStuff = model
                isShowingSavedSheet = true
            } catch {
                alertMessage = "Failed to save as Stuff"
                isShowingAlert = true
            }
        }
    }
}

#Preview(traits: .sampleData) {
    PlanView(
        selection: .init(
            period: .today,
            item: .init(
                title: "Organize photo library",
                rationale: "High-rated camera gear suggests photography focus; organizing helps future editing.",
                steps: [
                    "Back up all recent photos",
                    "Create year/month folders",
                    "Cull duplicates and low-quality shots",
                    "Tag favorites and add basic edits"
                ],
                estimatedMinutes: 120,
                resources: ["MacBook Pro", "Photos app", "External SSD"],
                risks: ["Running out of disk space", "Time overrun"],
                successCriteria: ["Library organized by month", "Favorites tagged"],
                priority: 1
            )
        )
    )
}
