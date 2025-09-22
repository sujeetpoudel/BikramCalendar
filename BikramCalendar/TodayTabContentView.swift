//
//  TodayContentView.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/20/25.
//

import SwiftUI

struct TodayTabContentView: View {
    var body: some View {
        VStack(spacing: 24) {
        NepaliAnalogClock()
            .frame(width: 220, height: 220)
            .padding(.bottom, 40)
        
            HStack(alignment: .top) {
                NepaliDigitalClock(bsDate: .constant(Constant.dummyBS))
                    .frame(width: 150, height: 80)
                
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.secondary.opacity(0.3), lineWidth: 1)
                        
                    }
                    .padding(.top)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    
                    Text(toBSString(bs: Today.date))
                        .font(.title2.bold())
                        .cornerRadius(10)
                        .foregroundColor(.primary.opacity(0.7))
                        .padding(.top, 15)
                    
                    
                    Text(PanchangaCalculator.getTithi(for: Today.ADDate))
                        .font(.headline.bold())
                        .cornerRadius(10)
                        .foregroundColor(.primary.opacity(0.7))
                    
                    Text(BSCalendar.toADString(Today.ADDate))
                        .font(.headline.bold())
                        .cornerRadius(10)
                        .foregroundColor(.primary.opacity(0.7))
                    
                    
                    
                }

            }
        }
        .padding()
    }
}

#Preview {
    TodayTabContentView()
}
