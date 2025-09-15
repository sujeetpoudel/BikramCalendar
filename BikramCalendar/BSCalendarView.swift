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
    /// Fixed reference for today (set externally or inside init)
    static var todayDayNumber: Int = -1
    
    /// Tracks the user’s current selection
    @Binding var userSelectedDay: Int?
    
    let bsDate: BSDate
    let nepaliWeekdaysAbbr = ["आइत","सोम","मङ्गल","बुध","बिही","शुक्र","शनि"]
    
    @State var changeSelectedDayForOverflow: Bool = false
    
    var body: some View {
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(50), spacing: 5), count: 7), spacing: 5) {
                
                // Weekday headers
                ForEach(nepaliWeekdaysAbbr, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(width: 50, height: 30)
                }
                
                // Days
                ForEach(1...42, id: \.self) { gridVal in
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
                                            } else
                                            
                                            if dayNumber == userSelectedDay ||
                                                        (!hasTodayHighlight && userSelectedDay == nil && dayNumber == Today.date.day) {
                                                Circle()
                                                    .stroke(.black.opacity(0.5), lineWidth: 2)
                                            }
                                            
                                        }
                                    )
                                    .foregroundColor(gridVal % 7 == 0 ? .red : .black)
                                    
                                
                                
                                let adCornerText: String = {
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

                                    if adDay == 1, let month = comps.month {
                                        let formatter = DateFormatter()
                                        formatter.calendar = calendar
                                        formatter.timeZone = tz
                                        formatter.dateFormat = "MMM"
                                        let monthAbbr = formatter.string(from: adDate)
                                        return "\(monthAbbr) \(adDay)"
                                    } else {
                                        return "\(adDay)"
                                    }
                                }()
                                
                                Text(adCornerText)
                                    .font(.caption2)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .offset(x: -4, y: -4)
                            }
                        }
                        .buttonStyle(.plain)
                        .background(Constant.gentleGray)
                        
                    } else {
                        Text("") // Empty
                            .frame(width: 52, height: 55)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

#Preview {
    BSCalendarView(userSelectedDay: .constant(1), bsDate: Constant.dummyBS)
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
