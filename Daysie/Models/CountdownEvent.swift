import Foundation
import SwiftData
import SwiftUI

enum RepeatOption: String, Codable, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

enum ReminderOption: String, Codable, CaseIterable {
    case oneDayBefore = "1 Day Before"
    case oneWeekBefore = "1 Week Before"
}

@Model
final class CountdownEvent {
    var id: UUID
    var name: String
    var date: Date
    var emoji: String
    var colorHex: String
    var notes: String
    var tags: [String]
    var repeatOptionRaw: String
    var workingDaysOnly: Bool
    var reminderOptionsRaw: [String]
    var createdAt: Date

    var repeatOption: RepeatOption {
        get { RepeatOption(rawValue: repeatOptionRaw) ?? .none }
        set { repeatOptionRaw = newValue.rawValue }
    }

    var reminderOptions: [ReminderOption] {
        get { reminderOptionsRaw.compactMap { ReminderOption(rawValue: $0) } }
        set { reminderOptionsRaw = newValue.map { $0.rawValue } }
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    init(
        id: UUID = UUID(),
        name: String,
        date: Date,
        emoji: String = "📅",
        colorHex: String = "#2196F3",
        notes: String = "",
        tags: [String] = [],
        repeatOption: RepeatOption = .none,
        workingDaysOnly: Bool = false,
        reminderOptions: [ReminderOption] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.emoji = emoji
        self.colorHex = colorHex
        self.notes = notes
        self.tags = tags
        self.repeatOptionRaw = repeatOption.rawValue
        self.workingDaysOnly = workingDaysOnly
        self.reminderOptionsRaw = reminderOptions.map { $0.rawValue }
        self.createdAt = createdAt
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
