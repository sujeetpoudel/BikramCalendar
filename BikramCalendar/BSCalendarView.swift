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
    
    @State var changeSelectedDayForOverflow: Bool = false
    
    /// All holidays in the given month
    var holidaysInMonth: [(day: Int, name: String)] {
        (1...bsDate.monthLength).compactMap { day -> (Int, String)? in
            let date = bsDate.withChangedDay(day)
            if let holiday = date.holiday, holiday != .saturday {
                return (day, holiday.rawValue)
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
                        .frame(width: 50, height: 30)
                }
                
                let extendedRow = bsDate.monthLength + bsDate.monthStartWeekday > 35 ? 42 : 35
                // Days
                ForEach(1...extendedRow, id: \.self) { gridVal in
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
                                                Circle()
                                                    .stroke(.black.opacity(0.5), lineWidth: 2)
                                            }
                                        }
                                    )
                                    .foregroundColor(bsDate.withChangedDay(dayNumber).isHoliday ? .red : .black)
                                
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
            if !holidaysInMonth.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("इभेन्ट्सहरू:")
                        .font(.headline)
                    
                    ForEach(holidaysInMonth, id: \.day) { holiday in
                        Text("📅 \(BSCalendar.toNepaliDigits(holiday.day)) – \(holiday.name)")
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.leading, 50)
                .padding(.top, 15)
            }
            
        }
    }
}
extension BSDate {
    enum Holiday: String {
        case saturday = "शनिबार"
        case newYear = "नयाँ बर्ष"
        case magheSankranti = "माघे सङ्क्रान्ति"
        case ganatantraDiwas = "गणतन्त्र दिवस"
        case prajatantraDiwas = "प्रजातन्त्र दिवस"
        case sahidDiwas = "शहीद दिवस"
        case christmasDay = "क्रिसमस डे"
        case engNewYear = "अंग्रेजी नयाँ बर्ष"
        case bhaitika = "भाइटीका"
        case dashain = "विजया दशमी"
    }
    
    var holiday: Holiday? {
        if self.isChristmasDay {
            return .christmasDay
        }
        if self.isEnglishNewYear {
            return .engNewYear
        }
        if day == 7 && month == 11 {
            return .prajatantraDiwas
        }
        if day == 16 && month == 10 {
            return .sahidDiwas
        }
        if day == 1 && month == 10 {
            return .magheSankranti
        }
        if day == 1 && month == 1 {
            return .newYear
        }
        if day == 15 && month == 2 && year > 2065 {
            return .ganatantraDiwas
        }
        if day == 6 && month == 7 && year == 2082 {
            return .bhaitika
        }
        if day == 16 && month == 6 && year == 2082 {
            return .dashain
        }
        if (day + monthStartWeekday) % 7 == 0 {
            return .saturday
        }
        return nil
    }

    // Check if the BSDate corresponds to Dec 25 (Christmas) in Kathmandu time
    var isChristmasDay: Bool {
        let date: Date = BSCalendar.toAD(from: self)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kathmandu")!
        let components = calendar.dateComponents([.month, .day], from: date)
        return components.month == 12 && components.day == 25
    }
    
    // Check if the BSDate corresponds to Jan 1 (English New Year) in Kathmandu time
    var isEnglishNewYear: Bool {
        let date: Date = BSCalendar.toAD(from: self)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kathmandu")!
        let components = calendar.dateComponents([.month, .day], from: date)
        return components.month == 1 && components.day == 1
    }

    var isHoliday: Bool {
        holiday != nil
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
