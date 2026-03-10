import Foundation
import WidgetKit

struct SharedEvent: Codable {
    let id: String
    let name: String
    let emoji: String
    let colorHex: String
    let date: Date
    let isDaysSince: Bool
}

struct AppGroupHelper {
    static let appGroupID = "group.com.evercount.app"
    static let eventsKey = "shared_events"

    static func saveEvents(_ events: [CountdownEvent]) {
        let shared = events.map { event in
            SharedEvent(
                id: event.id.uuidString,
                name: event.name,
                emoji: event.emoji,
                colorHex: event.colorHex,
                date: event.date,
                isDaysSince: event.isDaysSince
            )
        }
        guard let data = try? JSONEncoder().encode(shared),
              let defaults = UserDefaults(suiteName: appGroupID) else { return }
        defaults.set(data, forKey: eventsKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func loadEvents() -> [SharedEvent] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: eventsKey),
              let events = try? JSONDecoder().decode([SharedEvent].self, from: data) else {
            return []
        }
        return events
    }
}
