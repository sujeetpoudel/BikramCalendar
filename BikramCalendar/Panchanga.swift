//
//  Panchanga.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/22/25.
//

import Foundation

struct PanchangaCalculator {
    // Surya Siddhanta constants
    private static let YugaRotationSun: Double = 4320000
    private static let YugaRotationMoon: Double = 57753336
    private static let YugaRotationStar: Double = 1582237828
    private static let YugaCivilDays: Double = 1577917828
    private static let KaliEpoch: Double = 588465.5
    private static let PlanetApogeeSun: Double = 77.0 + 17.0 / 60.0
    private static let PlanetCircummSun: Double = 13.0 + 50.0 / 60.0
    private static let PlanetCircummMoon: Double = 31.0 + 50.0 / 60.0
    
    private static let rad = 180.0 / Double.pi
    
    private static func zero360(_ x: Double) -> Double {
        return x - floor(x / 360.0) * 360.0
    }
    private static func sinDeg(_ deg: Double) -> Double {
        return sin(deg / rad)
    }
    private static func arcsinDeg(_ x: Double) -> Double {
        return asin(x) * rad
    }
    
    // Mean longitude
    private static func meanLongitude(ahar: Double, rotation: Double) -> Double {
        return zero360(rotation * ahar * 360.0 / YugaCivilDays)
    }
    
    // Equation of center (manda)
    private static func mandaEquation(meanLong: Double, apogee: Double, circ: Double) -> Double {
        let arg = meanLong - apogee
        return arcsinDeg(circ / 360.0 * sinDeg(arg))
    }
    
    // True longitude of Sun
    private static func trueLongitudeSun(ahar: Double) -> Double {
        let meanLong = meanLongitude(ahar: ahar, rotation: YugaRotationSun)
        let manda = mandaEquation(meanLong: meanLong, apogee: PlanetApogeeSun, circ: PlanetCircummSun)
        return zero360(meanLong - manda)
    }
    
    // True longitude of Moon
    private static func trueLongitudeMoon(ahar: Double) -> Double {
        let meanLong = meanLongitude(ahar: ahar, rotation: YugaRotationMoon)
        let apogee = meanLongitude(ahar: ahar, rotation: -232238) + 90.0 // Rahu/Candrocca
        let manda = mandaEquation(meanLong: meanLong, apogee: apogee, circ: PlanetCircummMoon)
        return zero360(meanLong - manda)
    }
    
    // Julian Day from Gregorian date
    private static func toJulianDay(year: Int, month: Int, day: Int) -> Double {
        var y = year
        var m = month + 1
        if m <= 2 {
            y -= 1
            m += 12
        }
        let a = y / 100
        let b = 2 - a + a / 4
        return floor(365.25 * Double(y + 4716)) +
               floor(30.6001 * Double(m + 1)) +
               Double(day) + Double(b) - 1524.5
    }
    
    /// Get Tithi Name for a given Date (UTC)
    static func getTithi(for date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        let tz = TimeZone(identifier: "Asia/Kathmandu")!
        calendar.timeZone = tz
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        
        let jd = toJulianDay(year: y, month: m, day: d)
        let ahar = jd - KaliEpoch + 0.25
        
        let sunLong = trueLongitudeSun(ahar: ahar)
        let moonLong = trueLongitudeMoon(ahar: ahar)
        
        let tithiVal = zero360(moonLong - sunLong) / 12.0
        let tithiNum = Int(floor(tithiVal)) + 1
        
        let paksha = tithiNum <= 15 ? "शुक्ल पक्ष" : "कृष्ण पक्ष"
        let tithiDay = tithiNum > 15 ? tithiNum - 15 : tithiNum
        
        let tithiNames = [
            "प्रतिपदा", "द्वितीया", "तृतीया", "चतुर्थी", "पञ्चमी", "षष्ठी",
            "सप्तमी", "अष्टमी", "नवमी", "दशमी",
            "एकादशी", "द्वादशी", "त्रयोदशी", "चतुर्दशी", "पूर्णिमा", "अमावस्या"
        ]
        
        let tithiName: String
        if paksha == "कृष्ण पक्ष" && tithiDay == 15 {
            tithiName = tithiNames[15] // अमावस्या
        } else if paksha == "शुक्ल पक्ष" && tithiDay == 15 {
            tithiName = tithiNames[14] // पूर्णिमा
        } else {
            tithiName = tithiNames[tithiDay - 1]
        }
        
        return "\(paksha) - \(tithiName)"
    }
}
