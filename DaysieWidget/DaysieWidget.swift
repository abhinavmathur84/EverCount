import WidgetKit
import SwiftUI

// MARK: - Shared Model

struct WidgetEvent: Codable {
    let id: String
    let name: String
    let emoji: String
    let colorHex: String
    let date: Date
    let isDaysSince: Bool

    var daysValue: Int {
        let calendar = Calendar.current
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: startOfNow, to: startOfTarget).day ?? 0
    }

    var color: Color {
        var hex = colorHex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgb) else { return .blue }
        return Color(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

// MARK: - Timeline Entry

struct DaysieEntry: TimelineEntry {
    let date: Date
    let nextEvent: WidgetEvent?
    let upcomingEvents: [WidgetEvent]
}

// MARK: - Timeline Provider

struct DaysieProvider: TimelineProvider {
    func placeholder(in context: Context) -> DaysieEntry {
        let sample = WidgetEvent(
            id: "0",
            name: "Birthday",
            emoji: "🎂",
            colorHex: "#9C27B0",
            date: Date().addingTimeInterval(86400 * 12),
            isDaysSince: false
        )
        return DaysieEntry(date: Date(), nextEvent: sample, upcomingEvents: [sample])
    }

    func getSnapshot(in context: Context, completion: @escaping (DaysieEntry) -> Void) {
        completion(buildEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DaysieEntry>) -> Void) {
        let entry = buildEntry()
        let nextMidnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    private func buildEntry() -> DaysieEntry {
        var events: [WidgetEvent] = []
        if let defaults = UserDefaults(suiteName: "group.com.daysie.app"),
           let data = defaults.data(forKey: "shared_events"),
           let decoded = try? JSONDecoder().decode([WidgetEvent].self, from: data) {
            events = decoded
        }
        let upcoming = events
            .filter { !$0.isDaysSince && $0.daysValue >= 0 }
            .sorted { $0.date < $1.date }
        return DaysieEntry(date: Date(), nextEvent: upcoming.first, upcomingEvents: Array(upcoming.prefix(3)))
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: DaysieEntry

    var body: some View {
        if let event = entry.nextEvent {
            VStack(spacing: 6) {
                Text(event.emoji)
                    .font(.system(size: 36))
                Text("\(abs(event.daysValue))")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Text("DAYS LEFT")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .tracking(0.5)
                Text(event.name)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(
                LinearGradient(
                    colors: [event.color, event.color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                for: .widget
            )
        } else {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title)
                    .foregroundStyle(.secondary)
                Text("No events")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(Color(.systemGroupedBackground), for: .widget)
        }
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: DaysieEntry

    var body: some View {
        if entry.upcomingEvents.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("No upcoming events")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(Color(.systemGroupedBackground), for: .widget)
        } else {
            VStack(spacing: 0) {
                ForEach(Array(entry.upcomingEvents.enumerated()), id: \.element.id) { index, event in
                    HStack(spacing: 10) {
                        Text(event.emoji)
                            .font(.title3)
                            .frame(width: 36, height: 36)
                            .background(event.color.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.name)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .lineLimit(1)
                            Text(event.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 1) {
                            Text("\(abs(event.daysValue))")
                                .font(.system(.title3, design: .rounded, weight: .black))
                                .foregroundStyle(event.color)
                            Text("days")
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)

                    if index < entry.upcomingEvents.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(12)
            .containerBackground(Color(.systemGroupedBackground), for: .widget)
        }
    }
}

// MARK: - Widget Definitions

struct DaysieSmallWidget: Widget {
    let kind = "DaysieSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaysieProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Countdown")
        .description("Your next upcoming event at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

struct DaysieMediumWidget: Widget {
    let kind = "DaysieMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaysieProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming Events")
        .description("Your next 3 upcoming events.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget Bundle

@main
struct DaysieWidgetBundle: WidgetBundle {
    var body: some Widget {
        DaysieSmallWidget()
        DaysieMediumWidget()
    }
}
