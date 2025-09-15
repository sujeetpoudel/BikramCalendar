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
                CustomADDatePickerView(bsDate: $tempBSDate)
                
                Button {
                    bsDate = BSCalendar.toFullBS(from: tempBSDate)
                    userSelectedDay = bsDate.day
                    UserSelectedDate.date = bsDate.withChangedDay(bsDate.day)
                    dismiss?()
                } label: {
                    Text("छान्नुहोस्: \(tempBSDate.year.nepaliStr)-\(tempBSDate.month.nepaliStr)-\(tempBSDate.day.nepaliStr)")
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

struct CustomADDatePickerView: View {
    @Binding var bsDate: BSDate {
        didSet {
            print("Selected Date: \(bsDate)")
        }
    }
    
    var daysInSelectedMonth: Int {
        npMonthsData[bsDate.year - 2000][bsDate.month - 1] // Month index starts at 0
    }

    var years: [Int] = Array(2000...2099)
    private let months: [String] = [
        "बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज",
        "कार्तिक", "मंसिर", "पौष", "माघ", "फाल्गुन", "चैत"
    ]

    var body: some View {
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
                    Text(months[m - 1]).tag(m)
                }
            }
            .frame(width: 120)
            .clipped()

            // Day picker
            Picker("Day", selection: $bsDate.day) {
                ForEach(Array(1...daysInSelectedMonth), id: \.self) { d in
                    Text("\(d.nepaliStr)").tag(d)
                }
            }
            .frame(width: 60)
            .clipped()
        }
        .pickerStyle(WheelPickerStyle()) // makes them spin like locker
    }
}

#Preview {
    ContentView()
}

#Preview {
    @Previewable @State var bsDate: BSDate = Constant.dummyBS
    BSDatePicker(bsDate: $bsDate, userSelectedDay: .constant(1))
}
