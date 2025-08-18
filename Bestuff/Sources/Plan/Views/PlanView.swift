//
//  PlanView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/30.
//

import EventKit
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
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
    @State private var isShowingEventSavedAlert = false
    @State private var isShowingReminderSavedAlert = false
    @State private var lastSavedEventID: String?
    @State private var lastSavedReminderID: String?
    @State private var lastSavedReminderDueDate: Date?
    @State private var lastSavedReminderListName: String?

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
        .alert("Event Saved", isPresented: $isShowingEventSavedAlert) {
            Button("Open") {
                openCalendarEvent(id: lastSavedEventID)
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your calendar event was saved.")
        }
        .alert("Reminder Saved", isPresented: $isShowingReminderSavedAlert) {
            Button("Open Reminders") {
                openRemindersApp()
            }
            Button("OK", role: .cancel) {}
        } message: {
            let due = lastSavedReminderDueDate?.formatted(.dateTime) ?? ""
            let list = lastSavedReminderListName ?? ""
            if !due.isEmpty || !list.isEmpty {
                Text([due.isEmpty ? nil : "Due: \(due)", list.isEmpty ? nil : "List: \(list)"].compactMap(\.self).joined(separator: "\n"))
            } else {
                Text("Your reminder was saved.")
            }
        }
        #if canImport(EventKitUI)
        .sheet(isPresented: $isShowingEventEditor) {
            if let event = preparedEvent {
                EKEventEditView(store: EventKitService.shared.eventStore, event: event) { result in
                    switch result {
                    case .saved(let id):
                        lastSavedEventID = id
                        alertMessage = "Calendar event saved"
                        isShowingEventSavedAlert = true
                    case .deleted:
                        alertMessage = "Calendar event deleted"
                    case .canceled:
                        alertMessage = "Canceled"
                    }
                    isShowingEventEditor = false
                    if isShowingEventSavedAlert == false {
                        isShowingAlert = true
                    }
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
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                ShareLink(item: shareText(for: savedStuff))
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button("Copy", systemImage: "doc.on.doc") {
                                    copyToClipboard(shareText(for: savedStuff))
                                }
                            }
                        }
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
                let result = try await EventKitService.shared.addReminder(
                    title: selection.item.title,
                    notes: selection.item.rationale,
                    dueDate: dueDate,
                    steps: selection.item.steps,
                    expandSteps: expandSteps,
                    priority: selection.item.priority
                )
                lastSavedReminderID = result.id
                lastSavedReminderDueDate = result.dueDate
                lastSavedReminderListName = result.calendarTitle
                alertMessage = "Reminder saved"
                isShowingReminderSavedAlert = true
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
                tagModels.append(Tag.findOrCreate(name: selection.period.title, in: modelContext, type: .period))
                for resource in selection.item.resources.prefix(5) {
                    let trimmed = resource.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { continue }
                    tagModels.append(Tag.findOrCreate(name: trimmed, in: modelContext, type: .resource))
                }

                let model = StuffService.create(
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
            }
        }
    }

    private func shareText(for model: Stuff) -> String {
        var lines: [String] = []
        lines.append(model.title)
        if let note = model.note, !note.isEmpty {
            lines.append(note)
        }
        let tagLine = (model.tags ?? []).map(\.name).joined(separator: ", ")
        if !tagLine.isEmpty {
            lines.append("Tags: \(tagLine)")
        }
        lines.append("Occurred: \(model.occurredAt.formatted(.dateTime))")
        return lines.joined(separator: "\n")
    }

    private func copyToClipboard(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
        alertMessage = "Copied to clipboard"
        isShowingAlert = true
    }

    private func openCalendarEvent(id: String?) {
        #if canImport(UIKit)
        let store = EventKitService.shared.eventStore
        if let id, let event = store.event(withIdentifier: id) {
            let seconds = event.startDate.timeIntervalSinceReferenceDate
            if let url = URL(string: "calshow:\\(seconds)") {
                UIApplication.shared.open(url)
                return
            }
        }
        if let url = URL(string: "calshow:\\(Date().timeIntervalSinceReferenceDate)") {
            UIApplication.shared.open(url)
        }
        #elseif canImport(AppKit)
        if let url = URL(string: "calshow:\\(Date().timeIntervalSinceReferenceDate)") {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications/Calendar.app"))
        }
        #endif
    }

    private func openRemindersApp() {
        #if canImport(UIKit)
        if let url = URL(string: "x-apple-reminderkit://") {
            UIApplication.shared.open(url)
        }
        #elseif canImport(AppKit)
        if let url = URL(string: "x-apple-reminderkit://") {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/Applications/Reminders.app"))
        }
        #endif
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
