import Foundation
import SwiftData
import SwiftUI

class EventsViewModel: ObservableObject {
    @Published var selectedTag: String? = nil
    @Published var sortAscending: Bool = true
    @Published var searchText: String = ""

    func filteredAndSortedEvents(_ events: [CountdownEvent]) -> (upcoming: [CountdownEvent], past: [CountdownEvent], daysSince: [CountdownEvent]) {
        var filtered = events

        if let tag = selectedTag, !tag.isEmpty {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }

        let daysSince = filtered
            .filter { $0.isDaysSince }
            .sorted { $0.date > $1.date }

        let countdownEvents = filtered.filter { !$0.isDaysSince }

        let upcoming = countdownEvents
            .filter { !DateHelper.isPast(date: $0.date) }
            .sorted { a, b in
                sortAscending ? a.date < b.date : a.date > b.date
            }

        let past = countdownEvents
            .filter { DateHelper.isPast(date: $0.date) }
            .sorted { $0.date > $1.date }

        return (upcoming, past, daysSince)
    }

    func allTags(from events: [CountdownEvent]) -> [String] {
        let tagSet = Set(events.flatMap { $0.tags })
        return tagSet.sorted()
    }
}
