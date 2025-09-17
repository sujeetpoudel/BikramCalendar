//
//  BSCalendar.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/13/25.
//

import SwiftUI

struct BSDate {
    var year: Int
    var month: Int
    var day: Int
    var weekday: Int // 0 = Sun, 1 = Mon, ..., 6 = Sat
    var monthStartWeekday: Int
    var monthLength: Int
}

struct Today {
    // Existing dummy placeholder
    static var date: BSDate = Constant.dummyBS
    
    // Computed property to get current AD date in Kathmandu
    static var ADDate: Date {
        let tz = TimeZone(identifier: "Asia/Kathmandu")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tz
        // Get current date in Kathmandu timezone
        let now = Date()
        let components = calendar.dateComponents(in: tz, from: now)
        return calendar.date(from: components) ?? now
    }
}

class BSCalendar {

    private static let msPerDay: Int64 = 86_400_000
    private static let bsYearZero = 2000 // 2000 BS

    // Reference epoch: 14 April 1943 = 1 Baisakh 2000 BS
    static let bsEpoch: Int64 = {
        var components = DateComponents()
        components.year = 1943
        components.month = 4
        components.day = 13
        components.hour = 23
        components.minute = 45 // leap year delay 'may be'
        components.second = 0
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kathmandu")! // Nepal Time
        let date = calendar.date(from: components)!
        return Int64(date.timeIntervalSince1970 * 1000) // milliseconds since epoch
    }()

    static let bsMonths = [
        "बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज",
        "कार्तिक", "मंसिर", "पौष", "माघ", "फाल्गुन", "चैत"
    ]

    static let nepaliWeekdays = [
        "आइतबार", "सोमबार", "मङ्गलबार", "बुधबार", "बिहीबार", "शुक्रबार", "शनिबार"
    ]
    
    // Convert BSDate → BS using 14 April 1943 as epoch (1 Baisakh 2000 BS)
    static func toFullBS(from date: BSDate) -> BSDate {
        // Calculate total days since 14 April 1943
        let daysSinceEpoch = totalDaysUpto(bsDate: date)
        var diff = daysSinceEpoch
        var bsYear = bsYearZero // 2000 BS
        
        while bsYear < bsYearZero + npMonthsData.count {
            for monthIndex in 0..<12 {
                let daysInCurrentMonth = npMonthsData[bsYear - bsYearZero][monthIndex]
                if diff < daysInCurrentMonth {
                    let day = diff
                    let monthFirstWeekDay = (daysSinceEpoch + 3 - diff) % 7
                    let weekday = (monthFirstWeekDay + day - 1) % 7
                    print(nepaliWeekdays[monthFirstWeekDay])
                    BSCalendarView.todayDayNumber = day
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

    static func totalDaysUpto(bsDate: BSDate) -> Int {
        var totalDays = 0
        
        // 1. Add full years before the target year
        for y in bsYearZero..<bsDate.year {
            let yearIndex = y - bsYearZero
            totalDays += npMonthsData[yearIndex].last ?? 0 // last element = total days in that year
        }
        
        // 2. Add months before the target month in the current year
        let yearIndex = bsDate.year - bsYearZero
        if yearIndex >= 0 && yearIndex < npMonthsData.count {
            for m in 0..<(bsDate.month - 1) {
                totalDays += npMonthsData[yearIndex][m]
            }
        }
        
        // 3. Add days of the current month
        totalDays += bsDate.day
        
        return totalDays
    }

    // Convert AD → BS using 14 April 1943 as epoch (1 Baisakh 2000 BS)
    static func toBS(from date: Date) -> BSDate {
        // Calculate total days since 14 April 1943
        let daysSinceEpoch = Int(((date.timeIntervalSince1970 * 1000) - Double(bsEpoch)) / Double(msPerDay))
        let totalMs = (date.timeIntervalSince1970 * 1000) - Double(bsEpoch)
        let days = Int(totalMs / Double(msPerDay))
        let leftoverMs = totalMs.truncatingRemainder(dividingBy: Double(msPerDay))
        let hours = Int(leftoverMs / (1000 * 60 * 60))
        let minutes = Int((leftoverMs / (1000 * 60)).truncatingRemainder(dividingBy: 60))
        let seconds = Int((leftoverMs / 1000).truncatingRemainder(dividingBy: 60))
        print("\(days) days, \(hours)h \(minutes)m \(seconds)s since 2000/01/01 BS")
        var diff = daysSinceEpoch
        var bsYear = bsYearZero // 2000 BS
        
        while bsYear < bsYearZero + npMonthsData.count {
            for monthIndex in 0..<12 {
                let daysInCurrentMonth = npMonthsData[bsYear - bsYearZero][monthIndex]
                if diff < daysInCurrentMonth {
                    let day = diff + 1
                    let monthFirstWeekDay = (daysSinceEpoch + 3 - diff) % 7
                    let weekday = (monthFirstWeekDay + day - 1) % 7
                    print(nepaliWeekdays[monthFirstWeekDay], monthFirstWeekDay, weekday)
                    let date = BSDate(year: bsYear, month: monthIndex + 1, day: day, weekday: weekday, monthStartWeekday: monthFirstWeekDay, monthLength: daysInCurrentMonth)
                    return date
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
        let day = BSCalendarView.todayDayNumber < 0 ? bs.day : BSCalendarView.todayDayNumber
        let wd = (bs.monthStartWeekday + day - 1) % 7
        return "\(toNepaliDigits(day)) \(bsMonths[bs.month-1]) \(toNepaliDigits(bs.year)) \(nepaliWeekdays[wd])"
    }

}

#Preview {
    CalendarTabContentView()
}

extension BSCalendar {
    
    /// Convert BSDate → AD Date
    static func toAD(from bsDate: BSDate) -> Date {
        // 1. Compute total days since 1 Baisakh 2000 BS
        let totalDays = totalDaysUpto(bsDate: bsDate) - 1 // subtract 1 because epoch is day 1
        
        // 2. Compute milliseconds since epoch
        let msSinceEpoch = Int64(totalDays) * msPerDay
        
        // 3. Convert to Date
        let adDate = Date(timeIntervalSince1970: TimeInterval(bsEpoch + msSinceEpoch) / 1000)
        
        return adDate
    }
    
    /// Optional: also return components in NPT
    static func toADComponents(from bsDate: BSDate) -> DateComponents {
        let adDate = toAD(from: bsDate)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kathmandu")!
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: adDate)
    }
}
