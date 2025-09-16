//
//  BSDatePicker.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/13/25.
//

import SwiftUI

struct BSDatePicker: View {
    @Environment(\.popupDismiss) var dismiss
    
    @Binding var bsDate: BSDate
    @Binding var userSelectedDay: Int?
    @State private var tempBSDate: BSDate
    
    init(bsDate: Binding<BSDate>, userSelectedDay: Binding<Int?>) {
        self._bsDate = bsDate
        self._tempBSDate = State(initialValue: bsDate.wrappedValue)
        self._userSelectedDay = userSelectedDay
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                CustomDatePickerView(bsDate: $tempBSDate)
                
                Button {
                    bsDate = BSCalendar.toFullBS(from: tempBSDate)
                    userSelectedDay = bsDate.day
                    UserSelectedDate.date = bsDate.withChangedDay(bsDate.day)
                    dismiss?()
                } label: {
                    Text("छनोट गर्नुहोस्: \(tempBSDate.year.nepaliStr)-\(tempBSDate.month.nepaliStr)-\(tempBSDate.day.nepaliStr)")
                        .padding()
                        .background(Constant.gentleRed)
                        .foregroundColor(Constant.gentleBlack)
                        .cornerRadius(10)
                }
            }
            .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
            .background(Color.white.cornerRadius(20))
            .shadowedStyle()
            .padding(.horizontal, 16)

            Button {
                dismiss?()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .padding(8)
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, 29)
        }
    }
}

struct CustomDatePickerView: View {
    @Binding var bsDate: BSDate
    @State private var showAD: Bool = false // Toggle between BS and AD

    private let npMonths = [
        "बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज",
        "कार्तिक", "मंसिर", "पौष", "माघ", "फाल्गुन", "चैत"
    ]

    private let years = Array(2000...2099)

    var daysInSelectedMonth: Int {
        npMonthsData[bsDate.year - 2000][bsDate.month - 1] // month index 0
    }
    
    var adDateInKathmandu: Date {
        let adDate = BSCalendar.toAD(from: bsDate)
        let tz = TimeZone(identifier: "Asia/Kathmandu")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tz
        var comps = calendar.dateComponents([.year, .month, .day], from: adDate)
        comps.day! += 1 // need to understand better utc and ktm time
        return calendar.date(from: comps) ?? adDate
    }

    var body: some View {
        VStack {
            // Toggle for BS / AD
            Toggle(isOn: $showAD) {
                Text(showAD ? "ई.सं." : "बि.सं.")
            }
            .foregroundStyle(Constant.gentleBlack)
            .frame(width: 100)
            .toggleStyle(SwitchToggleStyle(tint: Color.blue.opacity(0.5)))

            if showAD {
                ADDatePicker(adDate: adDateInKathmandu) { newADDate in
                    bsDate = BSCalendar.toBS(from: newADDate)
                }
            } else {
                // BS Picker
                HStack(spacing: 0) {
                    // Year picker
                    Picker("Year", selection: $bsDate.year) {
                        ForEach(years, id: \.self) { y in
                            Text("\(y.nepaliStr)").tag(y)
                        }
                    }
                    .frame(width: 100)
                    .clipped()

                    // Month picker
                    Picker("Month", selection: $bsDate.month) {
                        ForEach(1...12, id: \.self) { m in
                            Text(npMonths[m - 1]).tag(m)
                        }
                    }
                    .frame(width: 120)
                    .clipped()

                    // Day picker
                    Picker("Day", selection: $bsDate.day) {
                        ForEach(1...daysInSelectedMonth, id: \.self) { d in
                            Text("\(d.nepaliStr)").tag(d)
                        }
                    }
                    .frame(width: 60)
                    .clipped()
                }
                .pickerStyle(WheelPickerStyle())
            }
        }
    }
}

struct ADDatePicker: View {
    @State var adDate: Date
    var onChange: (Date) -> Void

    private let tz = TimeZone(identifier: "Asia/Kathmandu")!
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        return cal
    }

    var body: some View {
        DatePicker(
            "",
            selection: Binding<Date>(
                get: {
                    // Build a new Date from year, month, day only
                    let comps = calendar.dateComponents([.year, .month, .day], from: adDate)
                    return calendar.date(from: comps) ?? adDate
                },
                set: { newDate in
                    // Construct Date from picked year/month/day
                    let comps = calendar.dateComponents([.year, .month, .day], from: newDate)
                    if let localDate = calendar.date(from: comps) {
                        adDate = localDate
                        onChange(localDate)
                    }
                }
            ),
            displayedComponents: [.date]
        )
        .datePickerStyle(WheelDatePickerStyle())
        .labelsHidden()
    }
}

#Preview {
    ContentView()
}

#Preview {
    @Previewable @State var bsDate: BSDate = Constant.dummyBS
    BSDatePicker(bsDate: $bsDate, userSelectedDay: .constant(1))
}
