import Foundation

struct DateHelper {
    static func daysRemaining(from now: Date = Date(), to targetDate: Date, workingDaysOnly: Bool = false) -> Int {
        if workingDaysOnly {
            return workingDaysBetween(from: now, to: targetDate)
        }
        let calendar = Calendar.current
        let startOfNow = calendar.startOfDay(for: now)
        let startOfTarget = calendar.startOfDay(for: targetDate)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTarget)
        return components.day ?? 0
    }

    static func workingDaysBetween(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        var count = 0
        var current = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)

        let isForward = current <= end

        while (isForward && current < end) || (!isForward && current > end) {
            let weekday = calendar.component(.weekday, from: current)
            if weekday != 1 && weekday != 7 { // Not Sunday (1) or Saturday (7)
                count += isForward ? 1 : -1
            }
            current = calendar.date(byAdding: .day, value: isForward ? 1 : -1, to: current)!
        }
        return count
    }

    static func formattedDaysLabel(days: Int) -> String {
        if days == 0 { return "Today" }
        if days == 1 { return "1 day left" }
        if days == -1 { return "1 day ago" }
        if days > 0 { return "\(days) days left" }
        return "\(-days) days ago"
    }

    static func isPast(date: Date) -> Bool {
        return date < Calendar.current.startOfDay(for: Date())
    }

    static func timeComponents(to targetDate: Date) -> (months: Int, days: Int, hours: Int, minutes: Int, seconds: Int) {
        let now = Date()
        let calendar = Calendar.current

        if targetDate >= now {
            let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: now, to: targetDate)
            return (
                months: components.month ?? 0,
                days: components.day ?? 0,
                hours: components.hour ?? 0,
                minutes: components.minute ?? 0,
                seconds: components.second ?? 0
            )
        } else {
            let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: targetDate, to: now)
            return (
                months: components.month ?? 0,
                days: components.day ?? 0,
                hours: components.hour ?? 0,
                minutes: components.minute ?? 0,
                seconds: components.second ?? 0
            )
        }
    }
}
