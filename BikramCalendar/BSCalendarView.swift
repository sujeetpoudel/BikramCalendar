//
//  BSCalendarView.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/13/25.
//

import SwiftUI

struct UserSelectedDate {
    static var date: BSDate = Constant.dummyBS
}

struct BSCalendarView: View {
    static var todayDayNumber: Int = -1
    @Binding var userSelectedDay: Int?
    
    let bsDate: BSDate
    let nepaliWeekdaysAbbr = ["आइत","सोम","मङ्गल","बुध","बिही","शुक्र","शनि"]
    
    private var extendedRows: Bool {
        bsDate.monthLength + bsDate.monthStartWeekday > 35
    }
    
    /// All holidays in the given month
    var holidaysInMonth: [(day: Int, name: String)] {
        (1...bsDate.monthLength).compactMap { day -> (Int, String)? in
            let date = bsDate.withChangedDay(day)
            if let holiday = date.holiday, holiday != .saturday, holiday != .holidayMention {
                return (day, holiday.rawValue)
            }
            return nil
        }
    }
    
    /// All holidays in the given month
    var eventsInMonth: [(day: Int, name: String)] {
        (1...bsDate.monthLength).compactMap { day -> (Int, String)? in
            let date = bsDate.withChangedDay(day)
            if let event = date.event {
                print(day, event.rawValue)
                return (day, event.rawValue)
            }
            return nil
        }
    }
    
    var body: some View {
        VStack {
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(50), spacing: 5), count: 7), spacing: 5) {
                
                // Weekday headers
                ForEach(nepaliWeekdaysAbbr, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(width: 50, height: 20)
                }
                
                let extendedRows = bsDate.monthLength + bsDate.monthStartWeekday > 35 ? 42 : 35
                
                // Days
                ForEach(1...extendedRows, id: \.self) { gridVal in
                    let dayNumber = gridVal - bsDate.monthStartWeekday
                    
                    if dayNumber >= 1 && dayNumber <= bsDate.monthLength {
                        Button {
                            userSelectedDay = dayNumber
                            UserSelectedDate.date = bsDate.withChangedDay(dayNumber)
                        } label: {
                            ZStack(alignment: .bottomTrailing) {
                                // Main day text
                                Text(BSCalendar.toNepaliDigits(dayNumber))
                                    .frame(width: 52, height: 55)
                                    .background(
                                        ZStack {
                                            let hasTodayHighlight: Bool = bsDate.month == Today.date.month && bsDate.year == Today.date.year
                                            if hasTodayHighlight && dayNumber == Today.date.day {
                                                Circle()
                                                    .fill(Color.blue.opacity(0.3))
                                            } else if dayNumber == userSelectedDay ||
                                                        (!hasTodayHighlight && userSelectedDay == nil && dayNumber == Today.date.day) {
                                                Rectangle()
                                                    .stroke(.gray.opacity(0.4), lineWidth: 4)
                                                    .cornerRadius(4)
                                            }
                                        }
                                    )
                                    .foregroundColor(bsDate.withChangedDay(dayNumber).isHoliday ? .red : .primary)
                                
                                // Corner AD date
                                Text(ADDateCornerText(dayNumber: dayNumber))
                                    .font(.caption2)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .offset(x: -4, y: -4)
                            }
                        }
                        .buttonStyle(.plain)
                        .background(Constant.gentleGray)
                        
                    } else {
                        Text("") // Empty slot
                            .frame(width: 52, height: 55)
                    }
                }
            }
            
            // Holidays list at the bottom
            if !holidaysInMonth.isEmpty || !eventsInMonth.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📅 इभेन्ट्सहरू:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    // Define two columns
                    let columns = [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ]
                    
                    // Combine holidays + events into one array with a flag
                    let combinedItems: [(day: Int, name: String, isHoliday: Bool)] =
                        holidaysInMonth.prefix(6).map { (day: $0.day, name: $0.name, isHoliday: true) } +
                        eventsInMonth.prefix(6).map { (day: $0.day, name: $0.name, isHoliday: false) }

                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                        ForEach(combinedItems, id: \.day) { item in
                            Text("\(BSCalendar.toNepaliDigits(item.day)) – \(item.name)")
                                .foregroundColor(item.isHoliday ? .red : .primary.opacity(0.7))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, extendedRows ? 10: 15)
            }
            
        }
    }
}

#Preview {
    BSCalendarView(userSelectedDay: .constant(8), bsDate: BSDate(year: 2082, month: 6, day: 16, weekday: 1, monthStartWeekday: 3, monthLength: 31))
}

#Preview {
    CalendarTabContentView()
}


#Preview {
    ContentView()
}

extension BSDate {
    /// Returns a new BSDate with only the day updated
    func withChangedDay(_ newDay: Int) -> BSDate {
        BSDate(
            year: self.year,
            month: self.month,
            day: newDay,
            weekday: self.weekday,
            monthStartWeekday: self.monthStartWeekday,
            monthLength: self.monthLength
        )
    }
    
    func withChangedMonth(_ newMonth: Int) -> BSDate {
        BSDate(
            year: self.year,
            month: newMonth,
            day: self.day,
            weekday: self.weekday,
            monthStartWeekday: self.monthStartWeekday,
            monthLength: self.monthLength
        )
    }
}

extension BSCalendarView {
    func ADDateCornerText(dayNumber: Int) -> String {
        let adDate = BSCalendar.toAD(from: BSDate(
            year: bsDate.year,
            month: bsDate.month,
            day: dayNumber,
            weekday: 0,
            monthStartWeekday: 0,
            monthLength: 0
        ))

        let calendar = Calendar(identifier: .gregorian)
        let tz = TimeZone(identifier: "Asia/Kathmandu")!
        let comps = calendar.dateComponents(in: tz, from: adDate)
        let adDay = comps.day ?? 0

        if adDay == 1 {
            let formatter = DateFormatter()
            formatter.calendar = calendar
            formatter.timeZone = tz
            formatter.dateFormat = "MMM"
            let monthAbbr = formatter.string(from: adDate)
            return "\(monthAbbr) \(adDay)"
        } else {
            return "\(adDay)"
        }
    }
}
