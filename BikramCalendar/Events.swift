//
//  Events.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/16/25.
//

import SwiftUI

extension BSDate {
    enum Holiday: String {
        case saturday = "शनिबार"
        case newYear = "नयाँ बर्ष"
        case magheSankranti = "माघे सङ्क्रान्ति"
        case ganatantraDiwas = "गणतन्त्र दिवस"
        case prajatantraDiwas = "प्रजातन्त्र दिवस"
        case sahidDiwas = "शहीद दिवस"
        case christmasDay = "क्रिसमस डे"
        case engNewYear = "अंग्रेजी नयाँ बर्ष"
        case prithviJayanti = "पृथ्वी जयन्ती"
        case labourDay = "अन्तर्राष्ट्रिय श्रमिक दिवस"
        case womensDay = "नारी दिवस"
        case bhaitika = "भाइटीका"
        case laxmiPuja = "लक्ष्मी पूजा"
        case dashain = "विजया दशमी"
        case dashainFulpati = "फूलपती"
        case chathParva = "छठ पर्व"
        case guruNanakJayanti = "गुरु नानक जयन्ती"
        case holidayMention = ""
    }
    
    var holiday: Holiday? {
        if day == 27 && month == 9 {
            return .prithviJayanti
        }
        if self.isChristmasDay {
            return .christmasDay
        }
        if self.isIntlLabourDay {
            return .labourDay
        }
        if self.isEnglishNewYear {
            return .engNewYear
        }
        if self.isWomensDay {
            return .womensDay
        }
        if day == 7 && month == 11 {
            return .prajatantraDiwas
        }
        if day == 16 && month == 10 {
            return .sahidDiwas
        }
        if day == 1 && month == 10 {
            return .magheSankranti
        }
        if day == 1 && month == 1 {
            return .newYear
        }
        if day == 15 && month == 2 && year > 2065 {
            return .ganatantraDiwas
        }
        if day == 16 && month == 6 && year == 2082 {
            return .dashain
        }
        if day == 13 && month == 6 && year == 2082 {
            return .dashainFulpati
        }
        if (day >= 13 && day <= 18) && month == 6 && year == 2082 {
            return .holidayMention // dashain slot 2082
        }
        if day == 6 && month == 7 && year == 2082 {
            return .bhaitika
        }
        if day == 3 && month == 7 && year == 2082 {
            return .laxmiPuja
        }
        if (day >= 3 && day <= 8) && month == 7 && year == 2082 {
            return .holidayMention // tihar slot 2082
        }
        if day == 10 && month == 7 && year == 2082 {
            return .chathParva
        }
        if day == 19 && month == 7 && year == 2082 {
            return .guruNanakJayanti
        }
        if (day + monthStartWeekday) % 7 == 0 {
            return .saturday
        }
        return nil
    }
    
    var isHoliday: Bool {
        holiday != nil
    }
}

// MARK: - Calendar in Kathmandu timezone
extension Calendar {
    static var gregorianKTM: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Kathmandu")!
        return cal
    }
}

// Holidays
extension BSDate {
    // Check if the BSDate corresponds to Dec 25 (Christmas) in Kathmandu time
    var isChristmasDay: Bool {
        let date: Date = BSCalendar.toAD(from: self)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kathmandu")!
        let components = calendar.dateComponents([.month, .day], from: date)
        return components.month == 12 && components.day == 25
    }
    
    var isIntlLabourDay: Bool {
        let date: Date = BSCalendar.toAD(from: self)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kathmandu")!
        let components = calendar.dateComponents([.month, .day], from: date)
        if components.month == 5 && components.day == 1 {
            print("Sujeet \(self) component is \(components)")
        }
        return components.month == 5 && components.day == 1
    }
    
    var isWomensDay: Bool {
        let date: Date = BSCalendar.toAD(from: self)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kathmandu")!
        let components = calendar.dateComponents([.month, .day], from: date)
        return components.month == 3 && components.day == 8
    }
    
    // Check if the BSDate corresponds to Jan 1 (English New Year) in Kathmandu time
    var isEnglishNewYear: Bool {
        let date: Date = BSCalendar.toAD(from: self)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Kathmandu")!
        let components = calendar.dateComponents([.month, .day], from: date)
        return components.month == 1 && components.day == 1
    }
}

extension BSDate {
    enum Event: String {
        case worldWaterDay = "विश्व पानी दिवस"
        case worldEarthDay = "पृथ्वी दिवस"
        case worldEnvironmentDay = "विश्व वातावरण दिवस"
        case worldRefugeeDay = "विश्व शरणार्थी दिवस"
        case internationalDayOfYoga = "अन्तर्राष्ट्रिय योग दिवस"
        case worldPopulationDay = "विश्व जनसंख्या दिवस"
        case internationalYouthDay = "अन्तर्राष्ट्रिय युवा दिवस"
        case internationalDayOfPeace = "अन्तर्राष्ट्रिय शान्ति दिवस"
        case worldTourismDay = "विश्व पर्यटन दिवस"
        case worldTeachersDay = "विश्व शिक्षक दिवस"
        case unitedNationsDay = "संयुक्त राष्ट्र दिवस"
        case worldFoodDay = "विश्व खाद्य दिवस"
        case worldHealthDay = "विश्व स्वास्थ्य दिवस"
        case worldAIDSDay = "विश्व एड्स दिवस"
        case humanRightsDay = "मानव अधिकार दिवस"
        case internationalDayOfFamilies = "अन्तर्राष्ट्रिय परिवार दिवस"
        case internationalLiteracyDay = "अन्तर्राष्ट्रिय साक्षरता दिवस"
    }
    
    var event: Event? {
        if isWorldWaterDay { return .worldWaterDay }
        if isWorldEarthDay { return .worldEarthDay }
        if isWorldEnvironmentDay { return .worldEnvironmentDay }
        if isWorldRefugeeDay { return .worldRefugeeDay }
        if isInternationalDayOfYoga { return .internationalDayOfYoga }
        if isWorldPopulationDay { return .worldPopulationDay }
        if isInternationalYouthDay { return .internationalYouthDay }
        if isInternationalDayOfPeace { return .internationalDayOfPeace }
        if isWorldTourismDay { return .worldTourismDay }
        if isWorldTeachersDay { return .worldTeachersDay }
        if isUnitedNationsDay { return .unitedNationsDay }
        if isWorldFoodDay { return .worldFoodDay }
        if isWorldHealthDay { return .worldHealthDay }
        if isWorldAIDSDay { return .worldAIDSDay }
        if isHumanRightsDay { return .humanRightsDay }
        if isInternationalDayOfFamilies { return .internationalDayOfFamilies }
        if isInternationalLiteracyDay { return .internationalLiteracyDay }
        return nil
    }
}

// MARK: - Event Checks
extension BSDate {
    var isWorldWaterDay: Bool { match(month: 3, day: 22) }
    var isWorldEarthDay: Bool { match(month: 4, day: 22) }
    var isWorldEnvironmentDay: Bool { match(month: 6, day: 5) }
    var isWorldRefugeeDay: Bool { match(month: 6, day: 20) }
    var isInternationalDayOfYoga: Bool { match(month: 6, day: 21) }
    var isWorldPopulationDay: Bool { match(month: 7, day: 11) }
    var isInternationalYouthDay: Bool { match(month: 8, day: 12) }
    var isInternationalDayOfPeace: Bool { match(month: 9, day: 21) }
    var isWorldTourismDay: Bool { match(month: 9, day: 27) }
    var isWorldTeachersDay: Bool { match(month: 10, day: 5) }
    var isUnitedNationsDay: Bool { match(month: 10, day: 24) }
    var isWorldFoodDay: Bool { match(month: 10, day: 16) }
    var isWorldHealthDay: Bool { match(month: 4, day: 7) }
    var isWorldAIDSDay: Bool { match(month: 12, day: 1) }
    var isHumanRightsDay: Bool { match(month: 12, day: 10) }
    var isInternationalDayOfFamilies: Bool { match(month: 5, day: 15) }
    var isInternationalLiteracyDay: Bool { match(month: 9, day: 8) }
    
    private func match(month: Int, day: Int) -> Bool {
        let date = BSCalendar.toAD(from: self)
        let comps = Calendar.gregorianKTM.dateComponents([.month, .day], from: date)
        return comps.month == month && comps.day == day
    }
}

#Preview {
    CalendarTabContentView()
}
