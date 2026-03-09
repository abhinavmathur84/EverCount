import SwiftUI
import SwiftData

struct AddEditEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var interstitialHelper: InterstitialAdHelper

    var existingEvent: CountdownEvent? = nil

    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var selectedEmoji: String = "📅"
    @State private var selectedColorHex: String = "#4B7BEC"
    @State private var repeatOption: RepeatOption = .none
    @State private var notes: String = ""
    @State private var tagsText: String = ""
    @State private var workingDaysOnly: Bool = false
    @State private var remindOneDayBefore: Bool = false
    @State private var remindOneWeekBefore: Bool = false

    let commonEmojis = [
        "📅", "🎂", "🎉", "💍", "✈️", "🎄",
        "🎆", "🏆", "💼", "🏠", "❤️", "⭐",
        "🌟", "🎓", "🎵", "⚽", "🎮", "📚",
        "🍕", "☀️", "🌙", "🌈", "🔥", "💎",
        "🎁", "🌺", "🐶", "🚀", "💻", "🎯"
    ]

    // Curated color palette
    private let presetColors: [(hex: String, color: Color)] = [
        ("#FF6B6B", Color(hex: "#FF6B6B") ?? .red),
        ("#FF9F43", Color(hex: "#FF9F43") ?? .orange),
        ("#FECA57", Color(hex: "#FECA57") ?? .yellow),
        ("#26DE81", Color(hex: "#26DE81") ?? .green),
        ("#2BCBBA", Color(hex: "#2BCBBA") ?? .teal),
        ("#45AAF2", Color(hex: "#45AAF2") ?? .blue),
        ("#4B7BEC", Color(hex: "#4B7BEC") ?? .indigo),
        ("#A55EEA", Color(hex: "#A55EEA") ?? .purple),
        ("#FD79A8", Color(hex: "#FD79A8") ?? .pink),
        ("#E17055", Color(hex: "#E17055") ?? .orange),
        ("#00B894", Color(hex: "#00B894") ?? .mint),
        ("#636E72", Color(hex: "#636E72") ?? .gray),
    ]

    var isEditing: Bool { existingEvent != nil }

    var body: some View {
        NavigationStack {
            Form {
                // Event Details
                Section {
                    HStack(spacing: 12) {
                        Text(selectedEmoji)
                            .font(.system(size: 32))
                            .frame(width: 48, height: 48)
                            .background(
                                (presetColors.first(where: { $0.hex == selectedColorHex })?.color ?? .accentColor)
                                    .opacity(0.15)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        TextField("Event name", text: $name)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                    .padding(.vertical, 4)

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .font(.system(.body, design: .rounded))
                } header: {
                    Text("Details")
                }

                // Emoji picker
                Section {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                        spacing: 8
                    ) {
                        ForEach(commonEmojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title2)
                                .frame(width: 46, height: 46)
                                .background(
                                    selectedEmoji == emoji
                                        ? (presetColors.first(where: { $0.hex == selectedColorHex })?.color ?? .accentColor).opacity(0.18)
                                        : Color(.tertiarySystemFill)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(
                                            presetColors.first(where: { $0.hex == selectedColorHex })?.color ?? .accentColor,
                                            lineWidth: 2
                                        )
                                        .opacity(selectedEmoji == emoji ? 1 : 0)
                                )
                                .scaleEffect(selectedEmoji == emoji ? 1.1 : 1)
                                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selectedEmoji)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                        selectedEmoji = emoji
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Emoji")
                }

                // Color palette
                Section {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6),
                        spacing: 12
                    ) {
                        ForEach(presetColors, id: \.hex) { preset in
                            ZStack {
                                Circle()
                                    .fill(preset.color)
                                    .frame(width: 40, height: 40)

                                if selectedColorHex == preset.hex {
                                    Circle()
                                        .strokeBorder(.white, lineWidth: 2.5)
                                        .frame(width: 40, height: 40)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .scaleEffect(selectedColorHex == preset.hex ? 1.15 : 1)
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: selectedColorHex)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    selectedColorHex = preset.hex
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }

                // Options
                Section {
                    Picker("Repeat", selection: $repeatOption) {
                        ForEach(RepeatOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    Toggle("Working Days Only", isOn: $workingDaysOnly)
                } header: {
                    Text("Options")
                }

                // Reminders
                Section {
                    Toggle("1 Day Before", isOn: $remindOneDayBefore)
                    Toggle("1 Week Before", isOn: $remindOneWeekBefore)
                } header: {
                    Text("Reminders")
                }

                // Tags
                Section {
                    TextField("e.g. personal, travel", text: $tagsText)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(.system(.body, design: .rounded))
                } header: {
                    Text("Tags (comma-separated)")
                }

                // Notes
                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .font(.system(.body, design: .rounded))
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle(isEditing ? "Edit Event" : "New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEvent() }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { loadExistingEvent() }
        }
    }

    private func loadExistingEvent() {
        guard let event = existingEvent else { return }
        name = event.name
        date = event.date
        selectedEmoji = event.emoji
        selectedColorHex = event.colorHex
        repeatOption = event.repeatOption
        notes = event.notes
        tagsText = event.tags.joined(separator: ", ")
        workingDaysOnly = event.workingDaysOnly
        remindOneDayBefore = event.reminderOptions.contains(.oneDayBefore)
        remindOneWeekBefore = event.reminderOptions.contains(.oneWeekBefore)
    }

    private func saveEvent() {
        var reminderOptions: [ReminderOption] = []
        if remindOneDayBefore { reminderOptions.append(.oneDayBefore) }
        if remindOneWeekBefore { reminderOptions.append(.oneWeekBefore) }

        if !reminderOptions.isEmpty {
            NotificationHelper.requestPermission()
        }

        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if let event = existingEvent {
            event.name = name
            event.date = date
            event.emoji = selectedEmoji
            event.colorHex = selectedColorHex
            event.repeatOption = repeatOption
            event.notes = notes
            event.tags = tags
            event.workingDaysOnly = workingDaysOnly
            event.reminderOptions = reminderOptions
            NotificationHelper.scheduleNotifications(for: event)
        } else {
            let newEvent = CountdownEvent(
                name: name,
                date: date,
                emoji: selectedEmoji,
                colorHex: selectedColorHex,
                notes: notes,
                tags: tags,
                repeatOption: repeatOption,
                workingDaysOnly: workingDaysOnly,
                reminderOptions: reminderOptions
            )
            modelContext.insert(newEvent)
            NotificationHelper.scheduleNotifications(for: newEvent)
            interstitialHelper.recordSaveAndShowIfNeeded()
        }

        dismiss()
    }
}
