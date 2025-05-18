//
//  Locale+extensions.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

extension Locale {
    static var customLanguageCode: String {
        if #available(iOS 16, *) {
            return Locale.current.identifier(.bcp47)
        } else {
            let languageCode = Locale.current.languageCode ?? "en"
            let regionCode = Locale.current.regionCode ?? "US"
            return "\(languageCode)-\(regionCode)"
        }
    }
}
