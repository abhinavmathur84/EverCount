import UserNotifications
import Foundation

struct NotificationHelper {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    static func scheduleNotifications(for event: CountdownEvent) {
        removeNotifications(for: event)

        guard !event.reminderOptions.isEmpty else { return }

        for option in event.reminderOptions {
            let daysOffset: Int
            switch option {
            case .oneDayBefore:
                daysOffset = -1
            case .oneWeekBefore:
                daysOffset = -7
            }

            guard let notificationDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: event.date),
                  notificationDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Upcoming: \(event.name)"
            let daysLeft = -daysOffset
            content.body = "\(event.emoji) \(event.name) is \(daysLeft == 1 ? "tomorrow" : "in \(daysLeft) days")!"
            content.sound = .default

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(event.id.uuidString)-\(option.rawValue)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    static func removeNotifications(for event: CountdownEvent) {
        let identifiers = ReminderOption.allCases.map { "\(event.id.uuidString)-\($0.rawValue)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
