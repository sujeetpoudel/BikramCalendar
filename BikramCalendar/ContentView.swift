//
//  ContentView.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text(BSCalendar.toBSString(date: Date()))
                .font(.title)
            
            BSCalendarView(bsDate: BSCalendar.toBS(from: Date()))
        }
    }
}

#Preview {
    ContentView()
}

import SwiftUI

import Foundation

struct BSDate {
    let year: Int
    let month: Int
    let day: Int
}

class BSCalendar {
    private static let msPerDay: Int64 = 86_400_000
    private static let bsEpoch: Int64 = -1789990200000 // 1913-04-13 AD
    private static let bsYearZero = 1970
    
    static let bsMonths = [
        "बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज",
        "कार्तिक", "मंसिर", "पौष", "माघ", "फाल्गुन", "चैत"
    ]
    
    
    private static let encodedMonthLengths: [Int] = [
        5315258,5314490,9459438,8673005,5315258,5315066,9459438,8673005,
        5315258,5314298,9459438,5327594,5315258,5314298,9459438,5327594,
        5315258,5314286,9459438,5315306,5315258,5314286,8673006,5315306,
        5315258,5265134,8673006,5315258,5315258,9459438,8673005,5315258,
        5314298,9459438,8673005,5315258,5314298,9459438,8473322,5315258,
        5314298,9459438,5327594,5315258,5314298,9459438,5327594,5315258,
        5314286,8673006,5315306,5315258,5265134,8673006,5315306,5315258,
        9459438,8673005,5315258,5314490,9459438,8673005,5315258,5314298,
        9459438,8473325,5315258,5314298,9459438,5327594,5315258,5314298,
        9459438,5327594,5315258,5314286,9459438,5315306,5315258,5265134,
        8673006,5315306,5315258,5265134,8673006,5315258,5314490,9459438,
        8673005,5315258,5314298,9459438,8669933,5315258,5314298,9459438,
        8473322,5315258,5314298,9459438,5327594,5315258,5314286,9459438,
        5315306,5315258,5265134,8673006,5315306,5315258,5265134,5527290,
        5527277,5527226,5527226,5528046,5527277,5528250,5528057,5527277,
        5527277
    ]
    
    // Convert AD → BS
    static func toBS(from date: Date) -> BSDate {
        let days = Int(((date.timeIntervalSince1970 * 1000) - Double(bsEpoch)) / Double(msPerDay)) + 1
        var remainingDays = days
        var year = bsYearZero
        
        while true {
            for m in 1...12 {
                let dM = daysInMonth(year: year, month: m)
                if remainingDays <= dM {
                    return BSDate(year: year, month: m, day: remainingDays)
                }
                remainingDays -= dM
            }
            year += 1
        }
        return BSDate(year: year, month: 1, day: 1)
    }

    // Days in a BS month
    private static func daysInMonth(year: Int, month: Int) -> Int {
        guard (1...12).contains(month) else { fatalError("Invalid month \(month)") }
        let delta = encodedMonthLengths[year - bsYearZero]
        return 29 + ((delta >> ((month - 1) << 1)) & 3)
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
    static func toBSString(date: Date) -> String {
        let bs = toBS(from: date)
        return "\(toNepaliDigits(bs.day)) \(bsMonths[bs.month-1]) \(toNepaliDigits(bs.year))"
    }
}



struct BSCalendarView: View {
    let bsDate: BSDate
    
    var body: some View {
        VStack {
           
            
            // Days grid (example: 30 days)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(1...32, id: \.self) { day in
                    if day <= 30 { // Simplified example
                        Text(BSCalendar.toNepaliDigits(day))
                            .frame(width: 40, height: 40)
                            .background(day == bsDate.day ? Color.blue.opacity(0.3) : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}
