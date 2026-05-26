import SwiftUI

struct IslamicCalendarView: View {
    @Environment(\.colorScheme) private var scheme
    
    private let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
    @State private var displayedMonth: Date = Date()
    
    // Important Islamic dates (month, day, name, icon)
    private let importantDates: [(month: Int, day: Int, name: String, icon: String)] = [
        (1, 1, "Islamic New Year", "sparkles"),
        (1, 10, "Day of Ashura", "heart.fill"),
        (3, 12, "Mawlid al-Nabi", "moon.stars.fill"),
        (7, 27, "Isra wal Mi'raj", "moon.fill"),
        (8, 15, "Shab-e-Barat", "moon.haze.fill"),
        (9, 1, "Ramadan Begins", "moon.stars.fill"),
        (9, 27, "Laylat al-Qadr", "star.fill"),
        (10, 1, "Eid al-Fitr", "gift.fill"),
        (12, 8, "Day of Arafah (Eve)", "mountain.2.fill"),
        (12, 9, "Day of Arafah", "mountain.2.fill"),
        (12, 10, "Eid al-Adha", "gift.fill"),
    ]
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Current Hijri date header
                    currentDateHeader
                    
                    // Month navigation
                    monthNavigation
                    
                    // Calendar grid
                    calendarGrid
                    
                    // Important dates section
                    importantDatesSection
                    
                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Current Date Header
    
    private var currentDateHeader: some View {
        VStack(spacing: 8) {
            let components = hijriCalendar.dateComponents([.day, .month, .year], from: Date())
            let monthName = hijriMonthName(components.month ?? 1)
            
            Text("\(components.day ?? 1) \(monthName) \(components.year ?? 1446)")
                .font(.title2.weight(.bold))
                .foregroundColor(.adaptiveText(scheme))
            
            Text("Hijri Date Today")
                .font(.caption.weight(.medium))
                .foregroundColor(.secondaryText(scheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.glassFill(scheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.glassBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Month Navigation
    
    private var monthNavigation: some View {
        let components = hijriCalendar.dateComponents([.month, .year], from: displayedMonth)
        let monthName = hijriMonthName(components.month ?? 1)
        
        return HStack {
            Button {
                moveMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text("\(monthName) \(components.year ?? 1446)")
                .font(.headline)
                .foregroundColor(.adaptiveText(scheme))
            
            Spacer()
            
            Button {
                moveMonth(1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.adaptiveAccent(scheme))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        let daysOfWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        let gridItems = generateCalendarDayItems()
        let displayComponents = hijriCalendar.dateComponents([.month], from: displayedMonth)
        let currentMonth = displayComponents.month ?? 1
        
        return VStack(spacing: 8) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.sectionTitle(scheme))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Day grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(gridItems, id: \.id) { item in
                    if let day = item.day {
                        let isToday = item.isToday
                        let isImportant = isImportantDate(month: currentMonth, day: day)
                        
                        ZStack {
                            if isToday {
                                Circle()
                                    .fill(Color.adaptiveAccent(scheme))
                                    .frame(width: 36, height: 36)
                            } else if isImportant {
                                Circle()
                                    .fill(Color.adaptiveAccent(scheme).opacity(0.2))
                                    .frame(width: 36, height: 36)
                            }
                            
                            Text("\(day)")
                                .font(.system(size: 15, weight: isToday ? .bold : .regular))
                                .foregroundColor(isToday ? (scheme == .light ? .white : .black) : .adaptiveText(scheme))
                        }
                        .frame(height: 40)
                    } else {
                        Text("")
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.glassFill(scheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.glassBorder(scheme), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Important Dates
    
    private var importantDatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IMPORTANT DATES")
                .font(.caption.weight(.semibold))
                .foregroundColor(.sectionTitle(scheme))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(Array(importantDates.enumerated()), id: \.offset) { index, date in
                    HStack(spacing: 14) {
                        Image(systemName: date.icon)
                            .font(.system(size: 16))
                            .foregroundColor(.adaptiveAccent(scheme))
                            .frame(width: 28)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(date.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.adaptiveText(scheme))
                            
                            Text("\(date.day) \(hijriMonthName(date.month))")
                                .font(.caption)
                                .foregroundColor(.secondaryText(scheme))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    
                    if index < importantDates.count - 1 {
                        Rectangle()
                            .fill(Color.dividerColor(scheme))
                            .frame(height: 1)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.glassFill(scheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.glassBorder(scheme), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helpers
    
    private func hijriMonthName(_ month: Int) -> String {
        let names = [
            "Muharram", "Safar", "Rabi al-Awwal", "Rabi al-Thani",
            "Jumada al-Ula", "Jumada al-Thani", "Rajab", "Sha'ban",
            "Ramadan", "Shawwal", "Dhul Qi'dah", "Dhul Hijjah"
        ]
        guard month >= 1, month <= 12 else { return "" }
        return names[month - 1]
    }
    
    private func moveMonth(_ delta: Int) {
        if let newDate = hijriCalendar.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = newDate
        }
    }
    
    private func isImportantDate(month: Int, day: Int) -> Bool {
        importantDates.contains { $0.month == month && $0.day == day }
    }
    
    private struct CalendarDayItem: Identifiable {
        let id: Int
        let day: Int?
        let isToday: Bool
    }
    
    private func generateCalendarDayItems() -> [CalendarDayItem] {
        var items: [CalendarDayItem] = []
        
        // Get the first day of the displayed month
        var comps = hijriCalendar.dateComponents([.year, .month], from: displayedMonth)
        comps.day = 1
        guard let firstDay = hijriCalendar.date(from: comps) else { return items }
        
        // Weekday of first day (1 = Sunday)
        let weekday = hijriCalendar.component(.weekday, from: firstDay)
        let daysInMonth = hijriCalendar.range(of: .day, in: .month, for: firstDay)?.count ?? 30
        
        // Today components
        let todayComponents = hijriCalendar.dateComponents([.year, .month, .day], from: Date())
        let displayComponents = hijriCalendar.dateComponents([.year, .month], from: displayedMonth)
        
        var id = 0
        
        // Empty cells before first day
        for _ in 0..<(weekday - 1) {
            items.append(CalendarDayItem(id: id, day: nil, isToday: false))
            id += 1
        }
        
        // Day cells
        for day in 1...daysInMonth {
            let isToday = todayComponents.year == displayComponents.year &&
                          todayComponents.month == displayComponents.month &&
                          todayComponents.day == day
            items.append(CalendarDayItem(id: id, day: day, isToday: isToday))
            id += 1
        }
        
        return items
    }
}

#Preview("Dark") {
    NavigationStack {
        IslamicCalendarView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        IslamicCalendarView()
    }
    .preferredColorScheme(.light)
}
