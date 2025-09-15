//
//  ContentView.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/1/25.
//

import SwiftUI
import PopupView

struct ContentView: View {

    @State private var bsDate: BSDate = BSDate(year: 2000, month: 1, day: 1, weekday: 3, monthStartWeekday: 3, monthLength: 30) {
        didSet {
            // works when left, right chevron, and आज tapped
            if userSelectedDay == nil {
                userSelectedDay = bsDate.day
            }
            
            if (userSelectedDay != nil) && bsDate.monthLength < userSelectedDay! {
                userSelectedDay = bsDate.monthLength
            }
                
        }
    }
    
    
    @State private var userSelectedDay: Int? = nil
    
    @State private var showDatePickerPopup: Bool = false
    
    init() {
        Today.date = BSCalendar.toBS(from: Date())
    }
    
    var body: some View {
        VStack {
            NepaliDigitalClock()
                .frame(width: 300, height: 100)
                .padding(.top, 50)
                .padding(.bottom, 50)
            
            if (userSelectedDay != nil) {
                BSCalendarHeaderView(
                    bsDate: bsDate.withChangedDay(userSelectedDay!),
                    showDatePickerPopup: $showDatePickerPopup,
                    changeMonth: changeMonth,
                    todayTapped: todayTapped
                )
            } else {
                BSCalendarHeaderView(
                    bsDate: BSDate(year: bsDate.year, month: bsDate.month, day: Today.date.day, weekday: 0, monthStartWeekday: 0, monthLength: 0),
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
    }
    
    private func todayTapped() {
        BSCalendarView.todayDayNumber = -1
        userSelectedDay = nil
        bsDate = BSCalendar.toBS(from: Today.ADDate)
    }
}

#Preview {
    ContentView()
}

struct ClockPreviewContainer: View {
    var body: some View {
        VStack(spacing: 24) {
            NepaliDigitalClock()
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
                // Face
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 4)
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)

                // Hour marks (12)
                ForEach(0..<12) { tick in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 2, height: size * 0.06)
                        .offset(y: -size/2 + (size * 0.06)/2)
                        .rotationEffect(.degrees(Double(tick) * 30))
                }

                // Hands
                let comps = calendar.dateComponents(in: tz, from: now)
                let h = comps.hour ?? 0
                let m = comps.minute ?? 0
                let s = comps.second ?? 0

                // Hour hand
                Hand(length: size * 0.22, thickness: 6)
                    .rotationEffect(.degrees(Double(h % 12) * 30 + Double(m) * 0.5))
                    .offset(x: 0, y: 0)

                // Minute hand
                Hand(length: size * 0.32, thickness: 4)
                    .rotationEffect(.degrees(Double(m) * 6 + Double(s) * 0.1))

                // Second hand
                Hand(length: size * 0.38, thickness: 1.5)
                    .foregroundColor(.red)
                    .rotationEffect(.degrees(Double(s) * 6))

                // Center cap
                Circle()
                    .fill(Color.primary)
                    .frame(width: 10, height: 10)

                // Nepali numerals around face (1..12)
                ForEach(1...12, id: \.self) { num in
                    let angle = Double(num) * 30 - 90
                    let radius = size * 0.42
                    let x = center.x + CGFloat(cos(angle * .pi / 180)) * radius
                    let y = center.y + CGFloat(sin(angle * .pi / 180)) * radius
                    Text(toNepaliDigits(num))
                        .font(.system(size: 14, weight: .semibold))
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

struct Hand: View {
    var length: CGFloat
    var thickness: CGFloat
    var foregroundColor: Color = .primary

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
    @State private var now = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    // Nepal timezone
    private let tz = TimeZone(identifier: "Asia/Kathmandu") ?? TimeZone.current
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "ne_NP") // optional for formatting
        return cal
    }()

    var body: some View {
        let components = calendar.dateComponents(in: tz, from: now)
        let hour24 = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        // 12-hour display
        let hour12 = (hour24 % 12 == 0) ? 12 : hour24 % 12

        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(toNepaliDigits(hour12, minDigits: 2))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .frame(width: 60, alignment: .trailing)

                Text(":")
                    .font(.system(size: 44, weight: .bold))

                Text(toNepaliDigits(minute, minDigits: 2))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .frame(width: 60, alignment: .trailing)

                Text(":")
                    .font(.system(size: 28, weight: .semibold))

                Text(toNepaliDigits(second, minDigits: 2))
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .frame(width: 40, alignment: .trailing)
            }
            

            // AM/PM and timezone label
            HStack(spacing: 10) {
                Text(nepaliAMPM(hour24))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Text("नेपाल") // or "NPT" if you prefer
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(timer) { input in
            self.now = input
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 2))
    }
}
