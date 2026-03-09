import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct DaysieApp: App {
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([CountdownEvent.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // Pre-populate with sample events on first launch
            let context = container.mainContext
            let fetchDescriptor = FetchDescriptor<CountdownEvent>()
            let existingEvents = try context.fetch(fetchDescriptor)
            if existingEvents.isEmpty {
                let calendar = Calendar.current
                let now = Date()
                let sampleEvents = [
                    CountdownEvent(
                        name: "Anniversary",
                        date: calendar.date(byAdding: .day, value: 45, to: now) ?? now,
                        emoji: "💍",
                        colorHex: "#E91E63",
                        notes: "Our special day",
                        tags: ["personal", "love"],
                        repeatOption: .yearly,
                        workingDaysOnly: false,
                        reminderOptions: [.oneDayBefore]
                    ),
                    CountdownEvent(
                        name: "Birthday",
                        date: calendar.date(byAdding: .day, value: 12, to: now) ?? now,
                        emoji: "🎂",
                        colorHex: "#9C27B0",
                        notes: "Don't forget the cake!",
                        tags: ["personal"],
                        repeatOption: .yearly,
                        workingDaysOnly: false,
                        reminderOptions: [.oneWeekBefore, .oneDayBefore]
                    ),
                    CountdownEvent(
                        name: "Vacation",
                        date: calendar.date(byAdding: .day, value: 60, to: now) ?? now,
                        emoji: "✈️",
                        colorHex: "#2196F3",
                        notes: "Pack sunscreen",
                        tags: ["travel"],
                        repeatOption: .none,
                        workingDaysOnly: false,
                        reminderOptions: []
                    ),
                    CountdownEvent(
                        name: "Christmas",
                        date: calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: 12, day: 25)) ?? now,
                        emoji: "🎄",
                        colorHex: "#4CAF50",
                        notes: "Ho ho ho",
                        tags: ["holiday"],
                        repeatOption: .yearly,
                        workingDaysOnly: false,
                        reminderOptions: [.oneWeekBefore]
                    ),
                    CountdownEvent(
                        name: "New Year",
                        date: calendar.date(from: DateComponents(year: calendar.component(.year, from: now) + 1, month: 1, day: 1)) ?? now,
                        emoji: "🎆",
                        colorHex: "#FF9800",
                        notes: "New beginnings",
                        tags: ["holiday"],
                        repeatOption: .yearly,
                        workingDaysOnly: false,
                        reminderOptions: []
                    )
                ]
                for event in sampleEvents {
                    context.insert(event)
                }
                try context.save()
            }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            EventListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
