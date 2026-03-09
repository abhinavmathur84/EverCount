import SwiftUI

struct EventDetailView: View {
    let event: CountdownEvent
    @Environment(\.colorScheme) var colorScheme
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var daysRemaining: Int {
        DateHelper.daysRemaining(to: event.date, workingDaysOnly: event.workingDaysOnly)
    }

    private var isPast: Bool {
        DateHelper.isPast(date: event.date)
    }

    private var timeComponents: (months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        DateHelper.timeComponents(to: event.date)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Hero card
                VStack(spacing: 14) {
                    Text(event.emoji)
                        .font(.system(size: 68))

                    Text(event.name)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(event.date.formatted(date: .long, time: .omitted))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))

                    // Main countdown number
                    VStack(spacing: 4) {
                        Text(daysRemaining == 0 ? "🎉" : "\(abs(daysRemaining))")
                            .font(.system(size: 68, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .monospacedDigit()

                        Text(daysRemaining == 0 ? "Today!" : (isPast ? "days ago" : "days left"))
                            .font(.system(.callout, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.88))
                            .textCase(.uppercase)
                            .tracking(1.2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.black.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [event.color, event.color.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: event.color.opacity(0.38), radius: 18, x: 0, y: 8)
                .padding(.horizontal)

                // Live countdown
                VStack(alignment: .leading, spacing: 12) {
                    Label(isPast ? "Time Since" : "Live Countdown", systemImage: "timer")
                        .font(.system(.footnote, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.8)

                    HStack(spacing: 8) {
                        TimeUnit(value: timeComponents.months, label: "MOS", color: event.color)
                        TimeUnit(value: timeComponents.days, label: "DAYS", color: event.color)
                        TimeUnit(value: timeComponents.hours, label: "HRS", color: event.color)
                        TimeUnit(value: timeComponents.minutes, label: "MIN", color: event.color)
                        TimeUnit(value: timeComponents.seconds, label: "SEC", color: event.color)
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal)

                // Tags
                if !event.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tags", systemImage: "tag")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.8)

                        FlowLayout(tags: event.tags, accentColor: event.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal)
                }

                // Notes
                if !event.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Notes", systemImage: "note.text")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.8)

                        Text(event.notes)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal)
                }

                // Share button
                ShareLink(item: "I'm counting down \(abs(daysRemaining)) days to \(event.name) \(event.emoji)! 🗓️") {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(.body, weight: .semibold))
                        Text("Share This Countdown")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(event.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal)

                AdaptiveBannerAdView()
                    .frame(height: 60)
                    .padding(.top, 4)
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}

struct TimeUnit: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct FlowLayout: View {
    let tags: [String]
    let accentColor: Color

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(accentColor.opacity(0.12))
                    .foregroundStyle(accentColor)
                    .clipShape(Capsule())
            }
        }
    }
}
