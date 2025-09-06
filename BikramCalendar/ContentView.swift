//
//  ContentView.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDate: Date = {
        let components = DateComponents(year: 2025, month: 8, day: 6)
        return Calendar.current.date(from: components)!
    }()

    var body: some View {
        // Convert selected AD date to BS
        var bsDate = BSCalendar.toBS(from: selectedDate)
        
        VStack {
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left").font(.title)
                }

                Spacer()

                Text(BSCalendar.toBSString(bs: bsDate))
                    .font(.title)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right").font(.title)
                }
            }
            .padding(.horizontal)
            
            BSCalendarView(bsDate: bsDate)
        }
    }

    // Function to add/subtract months in AD
    private func changeMonth(by months: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: months, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

#Preview {
    ContentView()
}

struct BSDate {
    let year: Int
    let month: Int
    var day: Int
    let weekday: Int // 0 = Sun, 1 = Mon, ..., 6 = Sat
    let monthStartWeekday: Int
    let monthLength: Int
}

class BSCalendar {
    private static let msPerDay: Int64 = 86_400_000
    private static let bsYearZero = 2000 // 2000 BS

    // Reference epoch: 14 April 1943 = 1 Baisakh 2000 BS
    static let bsEpoch: Int64 = {
        var components = DateComponents()
        components.year = 1943
        components.month = 4
        components.day = 14
        components.hour = 0
        components.minute = 0
        components.second = 0
        let calendar = Calendar.current
        let date = calendar.date(from: components)!
        return Int64(date.timeIntervalSince1970 * 1000)
    }()

    static let bsMonths = [
        "बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज",
        "कार्तिक", "मंसिर", "पौष", "माघ", "फाल्गुन", "चैत"
    ]

    static let nepaliWeekdays = [
        "आइतबार", "सोमबार", "मङ्गलबार", "बुधबार", "बिहीबार", "शुक्रबार", "शनिबार"
    ]

    // Convert AD → BS using 14 April 1943 as epoch (1 Baisakh 2000 BS)
    static func toBS(from date: Date) -> BSDate {
        // Calculate total days since 14 April 1943
        let daysSinceEpoch = Int(((date.timeIntervalSince1970 * 1000) - Double(bsEpoch)) / Double(msPerDay))
        var diff = daysSinceEpoch
        var bsYear = bsYearZero // 2000 BS
        
        while bsYear < bsYearZero + npMonthsData.count {
            for monthIndex in 0..<12 {
                let daysInCurrentMonth = npMonthsData[bsYear - bsYearZero][monthIndex]
                if diff < daysInCurrentMonth {
                    let day = diff + 1
                    let monthFirstWeekDay = (daysSinceEpoch + 3 - diff) % 7
                    let weekday = (monthFirstWeekDay + day - 1) % 7
                    print(nepaliWeekdays[monthFirstWeekDay])
                    BSCalendarView.selectedDay = BSCalendarView.selectedDay < 0 ? day : BSCalendarView.selectedDay
                    return BSDate(year: bsYear, month: monthIndex + 1, day: day, weekday: weekday, monthStartWeekday: monthFirstWeekDay, monthLength: daysInCurrentMonth)
                } else {
                    diff -= daysInCurrentMonth
                }
            }
            bsYear += 1
        }

        // Fallback (should not happen for supported range)
        return BSDate(year: 2000, month: 1, day: 1, weekday: 3, monthStartWeekday: 3, monthLength: 30)
    }

    // Days in a BS month
    static func daysInMonth(year: Int, month: Int) -> Int {
        precondition((1...12).contains(month), "Invalid month \(month)")
        let index = year - 2000  // since your table starts at 2000 BS
        return npMonthsData[index][month - 1]
    }

    // Nepali digits converter
    static func toNepaliDigits(_ number: Int) -> String {
        let map: [Character] = ["०","१","२","३","४","५","६","७","८","९"]
        return String(
            String(number).compactMap { digit -> Character? in
                if let value = digit.wholeNumberValue {
                    return map[value]
                }
                return digit
            }
        )
    }

    // Display as "१२ बैशाख २०८१"
    static func toBSString(bs: BSDate) -> String {
        let day = BSCalendarView.selectedDay
        let wd = (bs.monthStartWeekday + day - 1) % 7
        return "\(toNepaliDigits(day)) \(bsMonths[bs.month-1]) \(toNepaliDigits(bs.year)) \(nepaliWeekdays[wd])"
    }
}

struct BSCalendarView: View {
    static var selectedDay: Int = -1
    let bsDate: BSDate
    let nepaliWeekdaysAbbr = ["आइत","सोम","मङ्गल","बुध","बिही","शुक्र","शनि"]
    
    var body: some View {
        
        VStack {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(50), spacing: 5), count: 7), spacing: 5) {
                
                // Weekday headers
                ForEach(nepaliWeekdaysAbbr, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(width: 50, height: 50)
                }
                            
                // Actual days
                ForEach(1...42, id: \.self) { gridVal in
                    let dayNumber = gridVal - bsDate.monthStartWeekday
                    if dayNumber >= 1 && dayNumber <= bsDate.monthLength {
                        Text(BSCalendar.toNepaliDigits(dayNumber))
                            .frame(width: 50, height: 50)
                            .background(dayNumber == BSCalendarView.selectedDay ? Color.blue.opacity(0.3) : Color.clear)
                            .clipShape(Circle())
                            .background(Color.yellow)
                            .foregroundColor(gridVal % 7 == 0 ? .red : .black)
                    } else {
                        Text("") // Empty for days outside the current month
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
    }
}

let npMonthsData: [[Int]] = [
    [30,32,31,32,31,30,30,30,29,30,29,31,365], // 2000 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2001 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2002 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2003 BS
    [30,32,31,32,31,30,30,30,29,30,29,31,365], // 2004 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2005 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2006 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2007 BS
    [31,31,31,32,31,31,29,30,30,29,29,31,365], // 2008 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2009 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2010 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2011 BS
    [31,31,31,32,31,31,29,30,30,29,30,30,365], // 2012 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2013 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2014 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2015 BS
    [31,31,31,32,31,31,29,30,30,29,30,30,365], // 2016 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2017 BS
    [31,32,31,32,31,30,30,29,30,29,30,30,365], // 2018 BS
    [31,32,31,32,31,30,30,30,29,30,29,31,366], // 2019 BS
    [31,31,31,32,31,31,30,29,30,29,30,30,365], // 2020 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2021 BS
    [31,32,31,32,31,30,30,30,29,29,30,30,365], // 2022 BS
    [31,32,31,32,31,30,30,30,29,30,29,31,366], // 2023 BS
    [31,31,31,32,31,31,30,29,30,29,30,30,365], // 2024 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2025 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2026 BS
    [30,32,31,32,31,30,30,30,29,30,29,31,365], // 2027 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2028 BS
    [31,31,32,31,32,30,30,29,30,29,30,30,365], // 2029 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2030 BS
    [30,32,31,32,31,30,30,30,29,30,29,31,365], // 2031 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2032 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2033 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2034 BS
    [30,32,31,32,31,31,29,30,30,29,29,31,365], // 2035 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2036 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2037 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2038 BS
    [31,31,31,32,31,31,29,30,30,29,30,30,365], // 2039 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2040 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2041 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2042 BS
    [31,31,31,32,31,31,29,30,30,29,30,30,365], // 2043 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2044 BS
    [31,32,31,32,31,30,30,29,30,29,30,30,365], // 2045 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2046 BS
    [31,31,31,32,31,31,30,29,30,29,30,30,365], // 2047 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2048 BS
    [31,32,31,32,31,30,30,30,29,29,30,30,365], // 2049 BS
    [31,32,31,32,31,30,30,30,29,30,29,31,366], // 2050 BS
    [31,31,31,32,31,31,30,29,30,29,30,30,365], // 2051 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2052 BS
    [31,32,31,32,31,30,30,30,29,29,30,30,365], // 2053 BS
    [31,32,31,32,31,30,30,30,29,30,29,31,366], // 2054 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2055 BS
    [31,31,32,31,32,30,30,29,30,29,30,30,365], // 2056 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2057 BS
    [30,32,31,32,31,30,30,30,29,30,29,31,365], // 2058 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2059 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2060 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2061 BS
    [30,32,31,32,31,31,29,30,29,30,29,31,365], // 2062 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2063 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2064 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2065 BS
    [31,31,31,32,31,31,29,30,30,29,29,31,365], // 2066 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2067 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2068 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2069 BS
    [31,31,31,32,31,31,29,30,30,29,30,30,365], // 2070 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2071 BS
    [31,32,31,32,31,30,30,29,30,29,30,30,365], // 2072 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2073 BS
    [31,31,31,32,31,31,30,29,30,29,30,30,365], // 2074 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2075 BS
    [31,32,31,32,31,30,30,30,29,29,30,30,365], // 2076 BS
    [31,32,31,32,31,30,30,30,29,30,29,31,366], // 2077 BS
    [31,31,31,32,31,31,30,29,30,29,30,30,365], // 2078 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2079 BS
    [31,32,31,32,31,30,30,30,29,29,30,30,365], // 2080 BS
    [31,32,31,32,31,30,30,30,29,30,29,31,366], // 2081 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2082 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2083 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2084 BS
    [30,32,31,32,31,30,30,30,29,30,29,31,365], // 2085 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2086 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2087 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2088 BS
    [30,32,31,32,31,31,29,30,29,30,29,31,365], // 2089 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2090 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2091 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2092 BS
    [31,31,31,32,31,31,29,30,30,29,29,31,365], // 2093 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2094 BS
    [31,31,32,32,31,30,30,29,30,29,30,30,365], // 2095 BS
    [31,32,31,32,31,30,30,30,29,29,30,31,366], // 2096 BS
    [31,31,31,32,31,31,29,30,30,29,30,30,365], // 2097 BS
    [31,31,32,31,31,31,30,29,30,29,30,30,365], // 2098 BS
    [31,32,31,32,31,30,30,29,30,29,30,30,365], // 2099 BS
]
