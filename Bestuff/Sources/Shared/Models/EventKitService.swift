import EventKit
import Foundation

final class EventKitService {
    static let shared = EventKitService()

    private let store = EKEventStore()

    var eventStore: EKEventStore { store }

    private init() {}

    // MARK: - Public

    func prepareEvent(title: String, notes: String?, durationMinutes: Int, period: PlanPeriod, priority: Int) async throws -> EKEvent {
        try await requestAccessIfNeeded(for: .event)

        let startDate = defaultStartDate(for: period)
        let endDate = startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))

        let event = EKEvent(eventStore: store)
        event.calendar = pickCalendar(for: priority) ?? store.defaultCalendarForNewEvents
        event.title = prioritizedTitle(for: title, priority: priority, period: period)
        event.notes = notes
        event.startDate = startDate
        event.endDate = endDate
        return event
    }

    func saveEvent(_ event: EKEvent) throws -> String {
        try store.save(event, span: .thisEvent)
        return event.eventIdentifier
    }

    func addEvent(title: String, notes: String?, durationMinutes: Int, period: PlanPeriod, priority: Int) async throws -> String {
        let event = try await prepareEvent(title: title, notes: notes, durationMinutes: durationMinutes, period: period, priority: priority)
        // Prevent duplicates within a small time window
        if let existing = existingEventId(matching: event.title, near: event.startDate, end: event.endDate, in: event.calendar) {
            return existing
        }
        return try saveEvent(event)
    }

    func addReminder(title: String, notes: String?, period: PlanPeriod, steps: [String] = [], expandSteps: Bool = false, priority: Int) async throws -> String {
        try await requestAccessIfNeeded(for: .reminder)

        let reminder = EKReminder(eventStore: store)
        reminder.calendar = pickReminderCalendar(for: priority) ?? store.defaultCalendarForNewReminders()
        reminder.title = prioritizedTitle(for: title, priority: priority, period: period)
        reminder.notes = formattedNotes(notes: notes, steps: steps)

        let dueDate = defaultStartDate(for: period)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.dueDateComponents = components

        // Prevent duplicates (same title on same day)
        if let existing = try await existingReminderId(title: reminder.title, dueDate: dueDate, calendar: reminder.calendar) {
            return existing
        }

        try store.save(reminder, commit: true)

        if expandSteps, !steps.isEmpty {
            try createStepReminders(steps: steps, baseTitle: title, notes: notes, dueDate: dueDate, priority: priority, calendar: reminder.calendar)
        }

        return reminder.calendarItemIdentifier
    }

    struct ReminderSaveResult: Sendable {
        let id: String
        let dueDate: Date
        let calendarTitle: String?
    }

    func addReminder(title: String, notes: String?, dueDate: Date, steps: [String] = [], expandSteps: Bool = false, priority: Int) async throws -> ReminderSaveResult {
        try await requestAccessIfNeeded(for: .reminder)

        let reminder = EKReminder(eventStore: store)
        reminder.calendar = pickReminderCalendar(for: priority) ?? store.defaultCalendarForNewReminders()
        reminder.title = prioritizedTitle(for: title, priority: priority)
        reminder.notes = formattedNotes(notes: notes, steps: steps)

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        reminder.dueDateComponents = components

        // Prevent duplicates (same title on same day)
        if let existing = try await existingReminderId(title: reminder.title, dueDate: dueDate, calendar: reminder.calendar) {
            return .init(id: existing, dueDate: dueDate, calendarTitle: reminder.calendar?.title)
        }

        try store.save(reminder, commit: true)

        if expandSteps, !steps.isEmpty {
            try createStepReminders(steps: steps, baseTitle: title, notes: notes, dueDate: dueDate, priority: priority, calendar: reminder.calendar)
        }

        return .init(id: reminder.calendarItemIdentifier, dueDate: dueDate, calendarTitle: reminder.calendar?.title)
    }

    // MARK: - Private

    private enum AccessKind {
        case event
        case reminder
    }

    private func requestAccessIfNeeded(for kind: AccessKind) async throws {
        switch kind {
        case .event:
            let status = EKEventStore.authorizationStatus(for: .event)
            if status == .notDetermined {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    if #available(iOS 17, *) {
                        store.requestFullAccessToEvents { granted, error in
                            if let error {
                                continuation.resume(throwing: error)
                                return
                            }
                            if granted {
                                continuation.resume()
                            } else {
                                continuation.resume(throwing: NSError(domain: "Bestuff.EventKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Calendar access denied"]))
                            }
                        }
                    } else {
                        store.requestAccess(to: .event) { granted, error in
                            if let error {
                                continuation.resume(throwing: error)
                                return
                            }
                            if granted {
                                continuation.resume()
                            } else {
                                continuation.resume(throwing: NSError(domain: "Bestuff.EventKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Calendar access denied"]))
                            }
                        }
                    }
                }
            } else {
                if #available(iOS 17, *) {
                    if status != .fullAccess && status != .writeOnly {
                        throw NSError(domain: "Bestuff.EventKitService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Calendar access not authorized"])
                    }
                } else {
                    if status != .authorized {
                        throw NSError(domain: "Bestuff.EventKitService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Calendar access not authorized"])
                    }
                }
            }
        case .reminder:
            let status = EKEventStore.authorizationStatus(for: .reminder)
            if status == .notDetermined {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    if #available(iOS 17, *) {
                        store.requestFullAccessToReminders { granted, error in
                            if let error {
                                continuation.resume(throwing: error)
                                return
                            }
                            if granted {
                                continuation.resume()
                            } else {
                                continuation.resume(throwing: NSError(domain: "Bestuff.EventKitService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Reminders access denied"]))
                            }
                        }
                    } else {
                        store.requestAccess(to: .reminder) { granted, error in
                            if let error {
                                continuation.resume(throwing: error)
                                return
                            }
                            if granted {
                                continuation.resume()
                            } else {
                                continuation.resume(throwing: NSError(domain: "Bestuff.EventKitService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Reminders access denied"]))
                            }
                        }
                    }
                }
            } else {
                if #available(iOS 17, *) {
                    if status != .fullAccess && status != .writeOnly {
                        throw NSError(domain: "Bestuff.EventKitService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Reminders access not authorized"])
                    }
                } else {
                    if status != .authorized {
                        throw NSError(domain: "Bestuff.EventKitService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Reminders access not authorized"])
                    }
                }
            }
        }
    }

    func defaultStartDate(for period: PlanPeriod) -> Date {
        let calendar = Calendar.current
        let now = Date()

        func nextWeekdayMorning(from base: Date, hour: Int) -> Date {
            var date = base
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = 0
            date = calendar.date(from: components) ?? base

            if date < now {
                date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
            while calendar.isDateInWeekend(date) {
                date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
            return date
        }

        switch period {
        case .today:
            // Prefer next top-of-hour today; if weekend or late, move to next weekday morning 9:00
            let hour = calendar.component(.hour, from: now)
            if hour >= 18 {
                return nextWeekdayMorning(from: now, hour: 9)
            }
            if let nextHour = calendar.date(bySetting: .minute, value: 0, of: now)
                .flatMap({ calendar.date(byAdding: .hour, value: 1, to: $0) }) {
                if calendar.isDateInWeekend(nextHour) {
                    return nextWeekdayMorning(from: now, hour: 9)
                }
                return nextHour
            }
            return nextWeekdayMorning(from: now, hour: 9)
        case .thisWeek:
            // Within this week, pick the next weekday at 9:00; skip weekends
            return nextWeekdayMorning(from: now, hour: 9)
        case .nextTrip:
            // About a week out at 10:00, weekday only
            let oneWeek = calendar.date(byAdding: .day, value: 7, to: now) ?? now
            return nextWeekdayMorning(from: oneWeek, hour: 10)
        case .nextMonth:
            // First weekday of next month at 10:00
            var components = calendar.dateComponents([.year, .month], from: now)
            components.month = (components.month ?? 1) + 1
            components.day = 1
            components.hour = 10
            components.minute = 0
            var date = calendar.date(from: components) ?? now
            while calendar.isDateInWeekend(date) {
                date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
            return date
        case .nextYear:
            // First weekday in mid-January next year at 10:00
            var components = calendar.dateComponents([.year], from: now)
            components.year = (components.year ?? 1_970) + 1
            components.month = 1
            components.day = 15
            components.hour = 10
            components.minute = 0
            var date = calendar.date(from: components) ?? now
            while calendar.isDateInWeekend(date) {
                date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
            return date
        }
    }

    private func pickCalendar(for priority: Int) -> EKCalendar? {
        let candidates = store.calendars(for: .event)

        let namesForPriority: [Int: [String]] = [
            1: ["Bestuff High", "High", "Priority 1", "P1"],
            2: ["Bestuff Medium", "Medium", "Priority 2", "P2"],
            3: ["Bestuff Low", "Low", "Priority 3", "P3"]
        ]
        let targets = namesForPriority[priority] ?? []
        if let match = candidates.first(where: { calendar in
            guard let title = calendar.title as String? else { return false }
            return targets.contains(where: { title.localizedCaseInsensitiveContains($0) })
        }) {
            return match
        }
        return nil
    }

    private func pickReminderCalendar(for priority: Int) -> EKCalendar? {
        let candidates = store.calendars(for: .reminder)
        let namesForPriority: [Int: [String]] = [
            1: ["Bestuff High", "High", "Priority 1", "P1"],
            2: ["Bestuff Medium", "Medium", "Priority 2", "P2"],
            3: ["Bestuff Low", "Low", "Priority 3", "P3"]
        ]
        let targets = namesForPriority[priority] ?? []
        if let match = candidates.first(where: { calendar in
            guard let title = calendar.title as String? else { return false }
            return targets.contains(where: { title.localizedCaseInsensitiveContains($0) })
        }) {
            return match
        }
        return nil
    }

    private func existingEventId(matching title: String, near start: Date, end: Date, in calendar: EKCalendar?) -> String? {
        let calendars = calendar.map { [$0] } ?? store.calendars(for: .event)
        let windowStart = start.addingTimeInterval(-15 * 60)
        let windowEnd = end.addingTimeInterval(15 * 60)
        let predicate = store.predicateForEvents(withStart: windowStart, end: windowEnd, calendars: calendars)
        let events = store.events(matching: predicate)
        if let found = events.first(where: { $0.title == title }) {
            return found.eventIdentifier
        }
        return nil
    }

    private func existingReminderId(title: String, dueDate: Date, calendar: EKCalendar?) async throws -> String? {
        let calendars = calendar.map { [$0] } ?? store.calendars(for: .reminder)
        let predicate = store.predicateForReminders(in: calendars)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String?, Error>) in
            store.fetchReminders(matching: predicate) { reminders in
                guard let reminders else {
                    continuation.resume(returning: nil)
                    return
                }
                let day = Calendar.current.startOfDay(for: dueDate)
                let match = reminders.first { reminder in
                    guard let due = reminder.dueDateComponents?.date else { return false }
                    let sameDay = Calendar.current.isDate(Calendar.current.startOfDay(for: due), inSameDayAs: day)
                    return sameDay && reminder.title == title
                }
                continuation.resume(returning: match?.calendarItemIdentifier)
            }
        }
    }

    private func prioritizedTitle(for title: String, priority: Int, period: PlanPeriod? = nil) -> String {
        let prefix: String
        switch priority {
        case 1:
            prefix = "🔴 "
        case 2:
            prefix = "🟡 "
        default:
            prefix = "🟢 "
        }
        let periodTag = period.map { "[\($0.title)] " } ?? ""
        return prefix + periodTag + title
    }

    private func formattedNotes(notes: String?, steps: [String]) -> String? {
        var lines: [String] = []
        if let notes, !notes.isEmpty {
            lines.append(notes)
        }
        if !steps.isEmpty {
            lines.append("\nChecklist:")
            for (index, step) in steps.enumerated() {
                lines.append("- [ ] \(index + 1). \(step)")
            }
        }
        return lines.isEmpty ? notes : lines.joined(separator: "\n")
    }

    private func createStepReminders(steps: [String], baseTitle: String, notes: String?, dueDate: Date, priority: Int, calendar: EKCalendar) throws {
        for (index, step) in steps.enumerated() {
            let child = EKReminder(eventStore: store)
            child.calendar = calendar
            child.title = prioritizedTitle(for: "\(baseTitle) — Step \(index + 1): \(step)", priority: priority)
            child.notes = notes
            let comps = Calendar.current.dateComponents([.year, .month, .day], from: dueDate)
            child.dueDateComponents = comps
            try store.save(child, commit: false)
        }
        try store.commit()
    }
}
