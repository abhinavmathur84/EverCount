import WidgetKit
import SwiftUI
import SwiftData

struct CountdownEntry: TimelineEntry {
    let date: Date
    let eventName: String
    let eventEmoji: String
    let daysLeft: Int
    let eventColor: Color
}

struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), eventName: "Birthday", eventEmoji: "🎂", daysLeft: 12, eventColor: .purple)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        let entry = CountdownEntry(date: Date(), eventName: "Birthday", eventEmoji: "🎂", daysLeft: 12, eventColor: .purple)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        // Try to load the next event from SwiftData
        let entry = loadNextEvent() ?? CountdownEntry(date: Date(), eventName: "No Events", eventEmoji: "📅", daysLeft: 0, eventColor: .blue)

        // Refresh daily
        let nextUpdate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadNextEvent() -> CountdownEntry? {
        do {
            let schema = Schema([CountdownEvent.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)

            let descriptor = FetchDescriptor<CountdownEvent>(
                sortBy: [SortDescriptor(\.date)]
            )
            let events = try context.fetch(descriptor)

            guard let nextEvent = events.first(where: { !DateHelper.isPast(date: $0.date) }) else {
                return nil
            }

            let daysLeft = DateHelper.daysRemaining(to: nextEvent.date, workingDaysOnly: nextEvent.workingDaysOnly)
            return CountdownEntry(
                date: Date(),
                eventName: nextEvent.name,
                eventEmoji: nextEvent.emoji,
                daysLeft: daysLeft,
                eventColor: nextEvent.color
            )
        } catch {
            return nil
        }
    }
}

struct CountdownWidgetEntryView: View {
    var entry: CountdownEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: CountdownEntry

    var body: some View {
        ZStack {
            // ensure the background fills the entire widget area
            entry.eventColor
                .ignoresSafeArea()

            VStack(spacing: 4) {
                Text(entry.eventEmoji)
                    .font(.system(size: 28))
                Text(entry.eventName)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(entry.daysLeft == 0 ? "Today!" : "\(entry.daysLeft) days")
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            .padding(8)
        }
        // make the stack take up all available space so that the color
        // truly covers the widget, avoiding black bars at the edges
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(entry.eventColor, for: .widget)
    }
}

struct MediumWidgetView: View {
    let entry: CountdownEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(entry.eventEmoji)
                    .font(.system(size: 32))
                Text(entry.eventName)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("Next countdown")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            VStack(spacing: 4) {
                Text("\(entry.daysLeft)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(entry.daysLeft == 0 ? "Today!" : "days left")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(entry.eventColor, for: .widget)
    }
}

@main
struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProvider()) { entry in
            CountdownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daysie")
        .description("See your next upcoming event at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
