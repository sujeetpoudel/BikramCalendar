//
//  BikramCalendarApp.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/1/25.
//

import SwiftUI

@main
struct BikramCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    struct AppInfo {
        static var version: String {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
        static var build: String {
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        }
    }

}
