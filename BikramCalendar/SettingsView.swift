//
//  SettingsView.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/22/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Bikram Calendar \(BikramCalendarApp.AppInfo.version) (\(BikramCalendarApp.AppInfo.build))")
                .font(.largeTitle)
        }
    }
}

#Preview {
    SettingsView()
}
