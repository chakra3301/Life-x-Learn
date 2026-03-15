import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI

struct JournalHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.tutorTheme) private var theme

    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]

    @State private var selectedDate: Date = Date()
    @State private var showingEditor = false
    @State private var selectedEntry: JournalEntry?
    @State private var showCalendar = true

    private var entriesForSelectedDate: [JournalEntry] {
        entries.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
    }

    private var datesWithEntries: Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return Set(entries.map { formatter.string(from: $0.createdAt) })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TutorSpacing.lg) {
                    // Journal header — personal space feel
                    journalHeader

                    // Calendar strip
                    if showCalendar {
                        calendarSection
                    }

                    // Today's entries or first-time experience
                    if entries.isEmpty {
                        firstTimeView
                    } else {
                        entriesSection
                    }

                    // Streak info
                    if !entries.isEmpty {
                        streakSection
                    }
                }
                .padding()
            }
            .background(journalBackground)
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createNewEntry()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        withAnimation { showCalendar.toggle() }
                    } label: {
                        Image(systemName: showCalendar ? "calendar.circle.fill" : "calendar.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                if let entry = selectedEntry {
                    JournalEntryEditorView(entry: entry, isNew: true)
                }
            }
            .navigationDestination(for: JournalEntry.self) { entry in
                JournalEntryEditorView(entry: entry, isNew: false)
            }
        }
    }

    // MARK: - Personal Space Background

    private var journalBackground: some View {
        ZStack {
            theme.background
            // Subtle warm overlay for personal feel
            LinearGradient(
                colors: [
                    Color(hex: "#FFF8F0").opacity(0.3),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .center
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var journalHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedDate.formatted(date: .complete, time: .omitted))
                    .font(TutorTypography.subheadline)
                    .foregroundStyle(theme.textSecondary)

                if Calendar.current.isDateInToday(selectedDate) {
                    Text(entriesForSelectedDate.isEmpty ? "No entries today" : "\(entriesForSelectedDate.count) \(entriesForSelectedDate.count == 1 ? "entry" : "entries") today")
                        .font(TutorTypography.caption)
                        .foregroundStyle(theme.textSecondary)
                }
            }

            Spacer()

            // Private indicator
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                Text("Private")
                    .font(TutorTypography.caption2)
            }
            .foregroundStyle(theme.textSecondary.opacity(0.6))
            .padding(.horizontal, TutorSpacing.sm)
            .padding(.vertical, TutorSpacing.xxs)
            .background(theme.surfaceSecondary.opacity(0.5))
            .clipShape(Capsule())
        }
    }

    // MARK: - Calendar

    private var calendarSection: some View {
        VStack(spacing: TutorSpacing.sm) {
            // Month navigation
            HStack {
                Button {
                    moveMonth(-1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(theme.textSecondary)
                }

                Spacer()

                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(TutorTypography.headline)
                    .foregroundStyle(theme.textPrimary)

                Spacer()

                Button {
                    moveMonth(1)
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(theme.textSecondary)
                }
            }

            // Day labels
            let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
            HStack {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(TutorTypography.caption2)
                        .foregroundStyle(theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            let days = calendarDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: TutorSpacing.xs) {
                ForEach(days, id: \.self) { day in
                    if let day {
                        CalendarDayCell(
                            date: day,
                            isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                            isToday: Calendar.current.isDateInToday(day),
                            hasEntry: hasEntry(on: day),
                            accentColor: theme.accentColor
                        ) {
                            withAnimation { selectedDate = day }
                        }
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                }
            }
        }
        .padding()
        .background(theme.surfacePrimary.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: TutorRadius.lg))
    }

    // MARK: - First Time

    private var firstTimeView: some View {
        VStack(spacing: TutorSpacing.lg) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 56))
                .foregroundStyle(theme.accentColor.opacity(0.6))

            Text("Your personal space")
                .font(TutorTypography.title3)
                .foregroundStyle(theme.textPrimary)

            Text("This is your private journal. Reflect on your learning, track your thoughts, and grow. Everything here stays between you and your AI tutor.")
                .font(TutorTypography.body)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                createNewEntry()
            } label: {
                Label("Write your first entry", systemImage: "pencil")
                    .font(TutorTypography.bodyMedium)
                    .padding(.horizontal, TutorSpacing.xl)
                    .padding(.vertical, TutorSpacing.sm)
                    .background(theme.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, TutorSpacing.xxl)
    }

    // MARK: - Entries

    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.sm) {
            if !entriesForSelectedDate.isEmpty {
                // Entries for selected date
                ForEach(entriesForSelectedDate) { entry in
                    NavigationLink(value: entry) {
                        JournalEntryCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }

                // Add another entry button (notebook mode)
                Button {
                    createNewEntry()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add another entry")
                            .font(TutorTypography.callout)
                    }
                    .foregroundStyle(theme.accentColor)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.accentColor.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
                }
                .buttonStyle(.plain)
            } else {
                // No entries for this date
                VStack(spacing: TutorSpacing.sm) {
                    Text("No entries for this day")
                        .font(TutorTypography.body)
                        .foregroundStyle(theme.textSecondary)

                    if Calendar.current.isDateInToday(selectedDate) {
                        Button {
                            createNewEntry()
                        } label: {
                            Label("Write an entry", systemImage: "pencil")
                                .font(TutorTypography.bodyMedium)
                                .padding(.horizontal, TutorSpacing.lg)
                                .padding(.vertical, TutorSpacing.xs)
                                .background(theme.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, TutorSpacing.xl)
            }

            // Recent entries (if not viewing today)
            if !Calendar.current.isDateInToday(selectedDate) && !entries.isEmpty {
                Divider()
                    .padding(.vertical, TutorSpacing.sm)

                Text("Recent Entries")
                    .font(TutorTypography.headline)
                    .foregroundStyle(theme.textPrimary)

                ForEach(Array(entries.prefix(5))) { entry in
                    NavigationLink(value: entry) {
                        JournalEntryCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Streak

    private var streakSection: some View {
        let journalStreak = calculateJournalStreak()
        return GlassCard {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(TutorColors.streakFlame)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(journalStreak) day journal streak")
                        .font(TutorTypography.bodyMedium)
                        .foregroundStyle(theme.textPrimary)
                    Text("Keep reflecting to maintain your streak")
                        .font(TutorTypography.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Actions

    private func createNewEntry() {
        let entry = JournalEntry(content: "", type: .general)
        selectedEntry = entry
        showingEditor = true
    }

    // MARK: - Calendar Helpers

    private func calendarDays() -> [Date?] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingBlanks = firstWeekday - calendar.firstWeekday
        let adjustedBlanks = (leadingBlanks + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: adjustedBlanks)
        for day in range {
            var dayComponents = components
            dayComponents.day = day
            days.append(calendar.date(from: dayComponents))
        }

        return days
    }

    private func moveMonth(_ delta: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: delta, to: selectedDate) {
            withAnimation { selectedDate = newDate }
        }
    }

    private func hasEntry(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return datesWithEntries.contains(formatter.string(from: date))
    }

    private func calculateJournalStreak() -> Int {
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.createdAt) }).sorted(by: >)
        guard !uniqueDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: Date())
        guard let first = uniqueDays.first,
              first == today || first == calendar.date(byAdding: .day, value: -1, to: today) else {
            return 0
        }

        var streak = 0
        var checkDate = first
        for day in uniqueDays {
            if day == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if day < checkDate {
                break
            }
        }
        return streak
    }
}

// MARK: - Journal Entry Card

struct JournalEntryCard: View {
    @Environment(\.tutorTheme) private var theme
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: TutorSpacing.xs) {
            HStack {
                // Mood
                if let mood = entry.mood, !mood.isEmpty {
                    Text(mood)
                        .font(.title3)
                }

                // Time
                Text(entry.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(TutorTypography.caption)
                    .foregroundStyle(theme.textSecondary)

                // Type badge
                if entry.type != .general {
                    Text(entry.type.rawValue.capitalized)
                        .font(TutorTypography.caption2)
                        .padding(.horizontal, TutorSpacing.xs)
                        .padding(.vertical, 2)
                        .background(theme.accentColor.opacity(0.1))
                        .foregroundStyle(theme.accentColor)
                        .clipShape(Capsule())
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
            }

            // Content preview
            Text(entry.content)
                .font(TutorTypography.body)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(3)

            // Word count
            let words = entry.content.split(separator: " ").count
            Text("\(words) words")
                .font(TutorTypography.caption2)
                .foregroundStyle(theme.textSecondary)
        }
        .padding()
        .background(theme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: TutorRadius.md))
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEntry: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                    .foregroundStyle(
                        isSelected ? .white :
                            isToday ? accentColor :
                            .primary
                    )

                // Entry indicator dot
                Circle()
                    .fill(hasEntry ? (isSelected ? .white : accentColor) : .clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(
                Circle()
                    .fill(isSelected ? accentColor : .clear)
                    .frame(width: 34, height: 34)
            )
        }
        .buttonStyle(.plain)
    }
}
