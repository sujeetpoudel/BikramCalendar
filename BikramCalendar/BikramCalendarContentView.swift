//
//  ContentView.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/1/25.
//

import SwiftUI
import PopupView


import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1 // Index or tag of the tab you want to show first

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayTabContentView()
                .tabItem {
                    Label("आज", systemImage: "clock.fill") // Clock → आज
                }
                .tag(0)
            
            CalendarTabContentView()
                .tabItem {
                    Label("पात्रो", systemImage: "calendar") // Calendar → पात्रो
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("सेटिङ्स", systemImage: "gearshape.fill") // Settings → सेटिङ्स
                }
                .tag(2)
        }
    }
}

struct AajaView: View {
    
    @Binding var bsDate: BSDate
    
    var body: some View {
        
        HStack(alignment: .top) {
            NepaliDigitalClock(bsDate: $bsDate)
                .frame(width: 150, height: 80)
            
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.secondary.opacity(0.3), lineWidth: 1)
                    
                }
                .padding(.top)
                .padding(.bottom)
            
            VStack(alignment: .leading) {
                Text("आज")
                    .font(.headline.bold())
                    .padding(.top, 10)
                    .cornerRadius(10)
                    .foregroundColor(.primary.opacity(0.7))
                
                Text(toBSString(bs: Today.date))
                    .font(.title2.bold())
                    .cornerRadius(10)
                    .foregroundColor(.primary.opacity(0.7))
                
                Text(BSCalendar.toADString(Today.ADDate))
                    .font(.headline.bold())
                    .cornerRadius(10)
                    .foregroundColor(.primary.opacity(0.7))
                
            }

        }
    }
}

//#Preview {
//    AajaView(bsDate: Constant.dummyBS)
//}




struct CalendarTabContentView: View {

    @State private var bsDate: BSDate = BSDate(year: 2000, month: 1, day: 1, weekday: 3, monthStartWeekday: 3, monthLength: 30) {
        didSet {
            // works when left, right chevron, and आज tapped
            if userSelectedDay == nil {
                if bsDate.month != Today.date.month {
                    userSelectedDay = Today.date.day
                }
            }
            
            // For selecting 31st day and then exploring with month < 31 days
            if (userSelectedDay != nil) && bsDate.monthLength < userSelectedDay! {
                userSelectedDay = bsDate.monthLength
            }
                
        }
    }
    
    
    @State private var userSelectedDay: Int? = nil
    
    @State private var showDatePickerPopup: Bool = false
    
    init() {
        Today.date = BSCalendar.toBS(from: Today.ADDate)
    }
    
    var body: some View {
        VStack {
            AajaView(bsDate: $bsDate)
                .padding(20)
            
            if (userSelectedDay != nil) {
                BSCalendarHeaderView(
                    bsDate: bsDate.withChangedDay(userSelectedDay!),
                    showDatePickerPopup: $showDatePickerPopup,
                    changeMonth: changeMonth,
                    todayTapped: todayTapped
                )
            } else {
                BSCalendarHeaderView(
                    bsDate: bsDate,
                    showDatePickerPopup: $showDatePickerPopup,
                    changeMonth: changeMonth,
                    todayTapped: todayTapped
                )
            }
            BSCalendarView(userSelectedDay: $userSelectedDay, bsDate: bsDate)
            
            Spacer()
        }
        .onAppear() {
            bsDate = BSCalendar.toBS(from: Today.ADDate)
        }
        .popup(isPresented: $showDatePickerPopup) {
            BSDatePicker(bsDate: $bsDate,
                         userSelectedDay: $userSelectedDay)
        } customize: {
            $0
                .type(.floater())
                .disappearTo(.centerScale)
                .position(.bottom)
                .closeOnTap(false)
                .allowTapThroughBG(false)
                .backgroundColor(.black.opacity(0.4))
                .dragToDismiss(false)
        }
    }
    
    private func changeMonth(by months: Int, bsDate: BSDate) {
        var nm = bsDate.month + months
        var ny = bsDate.year
        if nm < 1 {
            ny -= 1
            nm = 12
        }
        if nm > 12 {
            ny += 1
            nm = 1
        }
        self.bsDate = BSCalendar.toFullBS(from: BSDate(year: ny, month: nm, day: 1, weekday: 0, monthStartWeekday: 0, monthLength: 0))
        Today.date = BSCalendar.toBS(from: Today.ADDate)
    }
    
    private func todayTapped() {
        BSCalendarView.todayDayNumber = -1
        userSelectedDay = nil
        bsDate = BSCalendar.toBS(from: Today.ADDate)
        Today.date = bsDate
    }
}

#Preview {
    ContentView()
}

struct ClockPreviewContainer: View {
    var body: some View {
        VStack(spacing: 24) {
            NepaliDigitalClock(bsDate: .constant(Constant.dummyBS))
            NepaliAnalogClock()
                .frame(width: 220, height: 220)
        }
        .padding()
    }
}

#Preview {
    ClockPreviewContainer()
}
struct NepaliAnalogClock: View {
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let tz = TimeZone(identifier: "Asia/Kathmandu") ?? TimeZone.current
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "ne_NP")
        return c
    }()

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)

            ZStack {
                // Clock face
                Circle()
                    .fill(Color(.systemBackground))   // adapts to light/dark
                    .shadow(radius: 4)

                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)

                // Hour marks (12 ticks)
                ForEach(0..<12) { tick in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 2, height: size * 0.04)
                        .offset(y: -size/2 + (size * 0.06)/2)
                        .rotationEffect(.degrees(Double(tick) * 30))
                }

                // Time components
                let comps = calendar.dateComponents(in: tz, from: now)
                let h = comps.hour ?? 0
                let m = comps.minute ?? 0
                let s = comps.second ?? 0

                // Hour hand
                Hand(length: size * 0.22, thickness: 6, foregroundColor: .primary)
                    .rotationEffect(.degrees(Double(h % 12) * 30 + Double(m) * 0.5))

                // Minute hand
                Hand(length: size * 0.32, thickness: 4, foregroundColor: .primary)
                    .rotationEffect(.degrees(Double(m) * 6 + Double(s) * 0.1))

                // Second hand
                Hand(length: size * 0.38, thickness: 1.5, foregroundColor: .red)
                    .rotationEffect(.degrees(Double(s) * 6))

                // Center cap
                Circle()
                    .fill(Color.primary)
                    .frame(width: 10, height: 10)

                // Nepali numerals
                ForEach(1...12, id: \.self) { num in
                    let angle = Double(num) * 30 - 90
                    let radius = size * 0.42
                    let x = center.x + CGFloat(cos(angle * .pi / 180)) * radius
                    let y = center.y + CGFloat(sin(angle * .pi / 180)) * radius
                    Text(toNepaliDigits(num))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .position(x: x, y: y)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .onReceive(timer) { input in
            now = input
        }
    }
}

// MARK: - Clock Hand
struct Hand: View {
    var length: CGFloat
    var thickness: CGFloat
    var foregroundColor: Color

    var body: some View {
        Rectangle()
            .fill(foregroundColor)
            .frame(width: thickness, height: length)
            .cornerRadius(thickness / 2)
            .offset(y: -length/2)
    }
}

func toNepaliDigits(_ number: Int) -> String {
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

fileprivate let nepaliDigits: [Character] = ["०","१","२","३","४","५","६","७","८","९"]

fileprivate func toNepaliDigits(_ number: Int, minDigits: Int = 1) -> String {
    let str = String(format: "%0\(minDigits)d", number)
    return String(str.map { ch in
        if let d = ch.wholeNumberValue { return nepaliDigits[d] }
        return ch
    })
}

fileprivate func nepaliAMPM(_ hour: Int) -> String {
    // use 12-hour hour input (1...12 or 0...11)
    // Nepali labels: पूर्वाह्न (AM), अपराह्न (PM)
    return hour < 12 ? "पूर्वाह्न AM" : "अपराह्न PM"
}

struct NepaliDigitalClock: View {
    @Binding var bsDate: BSDate
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let tz = TimeZone(identifier: "Asia/Kathmandu") ?? .current
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ne_NP")
        return cal
    }()
    
    @State var dayEpoch = BSCalendar.daysElapsedSinceEpoch
    
    init(bsDate: Binding<BSDate>) {
        _bsDate = bsDate
    }

    var body: some View {
        let components = calendar.dateComponents(in: tz, from: now)
        let hour24 = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        let hour12 = (hour24 % 12 == 0) ? 12 : hour24 % 12

        VStack(spacing: 3) {
            HStack(alignment: .center, spacing: 0) {
                // Hours
                Text(toNepaliDigits(hour12, minDigits: 2))
                    .font(.system(size: 32, weight: .semibold, design: .rounded))

                // Colon
                Text(":")
                    .font(.system(size: 28, weight: .medium))
                    .frame(width: 10, alignment: .center)

                // Minutes
                Text(toNepaliDigits(minute, minDigits: 2))
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .frame(width: 40, alignment: .trailing)

                // Colon
                Text(":")
                    .font(.system(size: 22, weight: .regular))
                    .frame(width: 10, alignment: .center)

                // Seconds
                Text(toNepaliDigits(second, minDigits: 2))
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .frame(width: 30, alignment: .leading)
                    .foregroundStyle(.secondary)

            }

            HStack(alignment: .center, spacing: 8) {
                Text(nepaliAMPM(hour24))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(3)
                    .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.secondary.opacity(0.3), lineWidth: 1)
                        )
                Text("नेपाल")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(timer) { now = $0
            if dayEpoch != BSCalendar.daysElapsedSinceEpoch,
               bsDate.month == Today.date.month && bsDate.year == Today.date.year && bsDate.day == Today.date.day {
                dayEpoch = BSCalendar.daysElapsedSinceEpoch
                bsDate = BSCalendar.toBS(from: Today.ADDate)
                Today.date = BSCalendar.toBS(from: Today.ADDate)
            }
            _ = BSCalendar.toBS(from: Today.ADDate)
        }
        .padding(8)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("⚙️ Settings Screen")
            .font(.largeTitle)
    }
}
