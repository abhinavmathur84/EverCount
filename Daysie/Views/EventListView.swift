import SwiftUI
import SwiftData

struct EventListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEvents: [CountdownEvent]
    @StateObject private var viewModel = EventsViewModel()
    @StateObject private var interstitialHelper = InterstitialAdHelper()
    @State private var showingAddEvent = false
    @State private var eventToEdit: CountdownEvent? = nil
    @Environment(\.colorScheme) var colorScheme

    private var groupedEvents: (upcoming: [CountdownEvent], past: [CountdownEvent]) {
        viewModel.filteredAndSortedEvents(allEvents)
    }

    private var allTags: [String] {
        viewModel.allTags(from: allEvents)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tag filter bar
                    if !allTags.isEmpty {
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

                    List {
                        // Upcoming events
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
                                        Button(role: .destructive) {
                                            deleteEvent(event)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button {
                                            eventToEdit = event
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.orange)
                                    }
                                }
                                .transition(.asymmetric(insertion: .slide, removal: .opacity))
                            }
                        }

                        // Past events
                        if !groupedEvents.past.isEmpty {
                            Section {
                                HStack {
                                    Text("PAST")
                                        .font(.system(.caption, design: .rounded, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                        .tracking(1.5)
                                    Spacer()
                                }
                                .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)

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
                                        Button(role: .destructive) {
                                            deleteEvent(event)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button {
                                            eventToEdit = event
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.orange)
                                    }
                                }
                                .transition(.asymmetric(insertion: .slide, removal: .opacity))
                            }
                        }

                        if groupedEvents.upcoming.isEmpty && groupedEvents.past.isEmpty {
                            ContentUnavailableView(
                                "No Events Yet",
                                systemImage: "calendar.badge.plus",
                                description: Text("Tap + to create your first countdown")
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .animation(.easeInOut, value: allEvents.count)

                    // Banner ad
                    AdaptiveBannerAdView()
                        .frame(height: 60)
                }
            }
            .navigationTitle("Daysie")
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
                    .environmentObject(interstitialHelper)
            }
            .sheet(item: $eventToEdit) { event in
                AddEditEventView(existingEvent: event)
                    .environmentObject(interstitialHelper)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search events")
        }
        .environmentObject(interstitialHelper)
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
