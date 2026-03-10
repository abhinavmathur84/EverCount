import SwiftUI
import SwiftData

struct EventListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEvents: [CountdownEvent]
    @StateObject private var viewModel = EventsViewModel()
    @State private var showingAddEvent = false
    @State private var eventToEdit: CountdownEvent? = nil

    private var groupedEvents: (upcoming: [CountdownEvent], past: [CountdownEvent], daysSince: [CountdownEvent]) {
        viewModel.filteredAndSortedEvents(allEvents)
    }

    private var allTags: [String] {
        viewModel.allTags(from: allEvents)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !allTags.isEmpty {
                    tagFilterBar
                }

                eventList

                BannerAdView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                    .frame(height: 50)
                    .background(Color(.secondarySystemGroupedBackground))
            }
            .navigationTitle("EverCount")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation { viewModel.sortAscending.toggle() }
                    } label: {
                        Image(systemName: viewModel.sortAscending ? "arrow.up.arrow.down.circle" : "arrow.up.arrow.down.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEditEventView()
            }
            .sheet(item: $eventToEdit) { event in
                AddEditEventView(existingEvent: event)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search events")
        }
        .onChange(of: allEvents.count) {
            AppGroupHelper.saveEvents(allEvents)
        }
    }

    private var tagFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedTag == nil,
                    action: { viewModel.selectedTag = nil }
                )
                ForEach(allTags, id: \.self) { tag in
                    FilterChip(
                        title: tag,
                        isSelected: viewModel.selectedTag == tag,
                        action: {
                            viewModel.selectedTag = viewModel.selectedTag == tag ? nil : tag
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var eventList: some View {
        List {
            upcomingSection
            daysSinceSection
            pastSection
            emptyState
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .animation(.easeInOut, value: allEvents.count)
    }

    @ViewBuilder
    private var upcomingSection: some View {
        if !groupedEvents.upcoming.isEmpty {
            Section {
                ForEach(groupedEvents.upcoming) { event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventCardView(event: event)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        deleteButton(for: event)
                        editButton(for: event)
                    }
                }
                .transition(.asymmetric(insertion: .slide, removal: .opacity))
            }
        }
    }

    @ViewBuilder
    private var daysSinceSection: some View {
        if !groupedEvents.daysSince.isEmpty {
            Section {
                sectionHeader("DAYS SINCE")
                ForEach(groupedEvents.daysSince) { event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventCardView(event: event)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        deleteButton(for: event)
                        editButton(for: event)
                    }
                }
                .transition(.asymmetric(insertion: .slide, removal: .opacity))
            }
        }
    }

    @ViewBuilder
    private var pastSection: some View {
        if !groupedEvents.past.isEmpty {
            Section {
                sectionHeader("PAST")
                ForEach(groupedEvents.past) { event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventCardView(event: event)
                            .opacity(0.62)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        deleteButton(for: event)
                        editButton(for: event)
                    }
                }
                .transition(.asymmetric(insertion: .slide, removal: .opacity))
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if groupedEvents.upcoming.isEmpty && groupedEvents.past.isEmpty && groupedEvents.daysSince.isEmpty {
            ContentUnavailableView(
                "No Events Yet",
                systemImage: "calendar.badge.plus",
                description: Text("Tap + to create your first countdown")
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(1.5)
            Spacer()
        }
        .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func deleteButton(for event: CountdownEvent) -> some View {
        Button(role: .destructive) {
            deleteEvent(event)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func editButton(for event: CountdownEvent) -> some View {
        Button {
            eventToEdit = event
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.orange)
    }

    private func deleteEvent(_ event: CountdownEvent) {
        NotificationHelper.removeNotifications(for: event)
        withAnimation {
            modelContext.delete(event)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
