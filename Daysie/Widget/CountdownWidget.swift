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
        let entry = loadNextEvent() ?? CountdownEntry(date: Date(), eventName: "No Events", eventEmoji: "📅", daysLeft: 0, eventColor: .blue)
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

            let descriptor = FetchDescriptor<CountdownEvent>(sortBy: [SortDescriptor(\.date)])
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
        VStack(spacing: 4) {
            Text(entry.eventEmoji)
                .font(.system(size: 30))

            Text(entry.daysLeft == 0 ? "Today!" : "\(entry.daysLeft)")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
                .minimumScaleFactor(0.6)

            if entry.daysLeft != 0 {
                Text("days left")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .textCase(.uppercase)
                    .tracking(0.6)
            }

            Text(entry.eventName)
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 2)
        }
        .containerBackground(
            LinearGradient(
                colors: [entry.eventColor, entry.eventColor.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .widget
        )
    }
}

struct MediumWidgetView: View {
    let entry: CountdownEntry

    var body: some View {
        HStack(spacing: 12) {
            // Left: emoji + name
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.eventEmoji)
                    .font(.system(size: 34))

                Spacer()

                Text(entry.eventName)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text("upcoming")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
                    .textCase(.uppercase)
                    .tracking(0.6)
            }

            Spacer()

            // Right: days badge
            VStack(spacing: 3) {
                Text(entry.daysLeft == 0 ? "🎉" : "\(entry.daysLeft)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)

                Text(entry.daysLeft == 0 ? "Today!" : "days left")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .frame(minWidth: 80)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(.black.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .containerBackground(
            LinearGradient(
                colors: [entry.eventColor, entry.eventColor.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .widget
        )
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
