import SwiftUI

struct EventCardView: View {
    let event: CountdownEvent
    @Environment(\.colorScheme) var colorScheme

    private var daysValue: Int {
        abs(DateHelper.daysRemaining(to: event.date, workingDaysOnly: event.workingDaysOnly))
    }

    private var daysRemaining: Int {
        DateHelper.daysRemaining(to: event.date, workingDaysOnly: event.workingDaysOnly)
    }

    private var isPast: Bool {
        DateHelper.isPast(date: event.date)
    }

    private var isUrgent: Bool {
        !event.isDaysSince && !isPast && daysRemaining <= 7
    }

    private var counterLabel: String {
        if event.isDaysSince { return "days\nsince" }
        if daysRemaining == 0 { return "" }
        return isPast ? "days\nago" : "days\nleft"
    }

    var body: some View {
        HStack(spacing: 0) {
            // Emoji bubble
            Text(event.emoji)
                .font(.system(size: 36))
                .frame(width: 58, height: 58)
                .background(.white.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.leading, 16)

            // Event info
            VStack(alignment: .leading, spacing: 5) {
                Text(event.name)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(.caption, design: .rounded, weight: .regular))
                    .foregroundStyle(.white.opacity(0.78))

                if !event.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(event.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.white.opacity(0.22))
                                .clipShape(Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .padding(.leading, 12)

            Spacer(minLength: 8)

            // Days counter panel
            VStack(spacing: 2) {
                if !event.isDaysSince && daysRemaining == 0 {
                    Text("Today")
                        .font(.system(.callout, design: .rounded, weight: .black))
                        .foregroundStyle(.white)
                } else {
                    Text("\(daysValue)")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                    Text(counterLabel)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 72)
            .frame(maxHeight: .infinity)
            .background(.black.opacity(0.15))
        }
        .frame(minHeight: 88)
        .background(
            LinearGradient(
                colors: [event.color, event.color.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(
            color: event.color.opacity(isUrgent ? 0.55 : 0.28),
            radius: isUrgent ? 14 : 7,
            x: 0, y: 4
        )
    }
}
