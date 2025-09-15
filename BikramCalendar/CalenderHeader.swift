//
//  CalenderHeader.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/13/25.
//

import SwiftUI

struct BSCalendarHeaderView: View {
    let bsDate: BSDate
    @Binding var showDatePickerPopup: Bool
    let changeMonth: (Int, BSDate) -> Void
    let todayTapped: () -> Void
    
    var body: some View {
        HStack {
            // Current BS date
            Text(toBSString(bs: bsDate))
                .font(.headline.bold())
                .multilineTextAlignment(.center)
                .frame(width: 120)
                .foregroundColor(.red)
            
            // .font(.system(size: 44, weight: .bold, design: .rounded))
            // Show date picker
            Button {
                showDatePickerPopup = true
            } label: {
                Image(systemName: "chevron.down")
                    .font(.subheadline)
                    .foregroundStyle(Constant.gentleBlack)
                    .padding(14)
                    .background(Constant.gentleRed)
                    .cornerRadius(20)
            }
            .padding(.trailing, 0)
            
            Spacer()
            
            // Today button
            Button {
                todayTapped()
            } label: {
                Text("आज")
                    .font(.caption.bold())
                    .padding(11)
                    .background(Constant.gentleGray)
                    .cornerRadius(10)
                    .foregroundStyle(Constant.gentleBlack)
            }
            
            // Previous month
            Button {
                changeMonth(-1, bsDate)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline)
                    .foregroundStyle(Constant.gentleBlack)
                    .padding(11)
                    .background(Constant.gentleGray)
                    .cornerRadius(10)
            }
            .padding(.trailing, 20)
            
            // Next month
            Button {
                changeMonth(1, bsDate)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(Constant.gentleBlack)
                    .padding(11)
                    .background(Constant.gentleGray)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}

#Preview {
    BSCalendarHeaderView(
        bsDate: Constant.dummyBS,              // dummy binding
        showDatePickerPopup: .constant(false), // dummy binding
        changeMonth: { _,_  in },                 // empty closure
        todayTapped: { }                       // empty closure
    )
}

let bsMonths = [
    "बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज",
    "कार्तिक", "मंसिर", "पौष", "माघ", "फाल्गुन", "चैत"
]

let nepaliWeekdays = [
    "आइतबार", "सोमबार", "मङ्गलबार", "बुधबार", "बिहीबार", "शुक्रबार", "शनिबार"
]

func toBSString(bs: BSDate) -> String {
    let day = bs.day
    let wd = (bs.monthStartWeekday + day - 1) % 7
    return "\(day.nepaliStr) \(bsMonths[bs.month-1])\n \(bs.year.nepaliStr) \(nepaliWeekdays[wd])"
}
