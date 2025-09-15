//
//  Extensions.swift
//  BikramCalendar
//
//  Created by Sujeet Poudel on 9/13/25.
//

import Foundation
import SwiftUI

extension View {
    func shadowedStyle() -> some View {
        self
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 0)
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 0)
    }
}

extension Int {
    var nepaliStr: String {
        let map: [Character] = ["०","१","२","३","४","५","६","७","८","९"]
        return String(
            String(self).compactMap { digit -> Character? in
                if let value = digit.wholeNumberValue {
                    return map[value]
                }
                return digit
            }
        )
    }
}
