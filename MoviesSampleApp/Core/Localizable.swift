//
//  Localizable.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

enum Localizable: String {
    case movieListTitle
    case retryButtonTitle
    case errorAlertTitle
    case releaseDate
    case internetErrorTitle
    case internetErrorMessage

    var localized: String {
        NSLocalizedString(rawValue, comment: String())
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments)
    }
}
