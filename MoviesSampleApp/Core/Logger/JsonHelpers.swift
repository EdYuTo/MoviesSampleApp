//
//  JsonHelpers.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 06/07/25.
//

import Foundation

enum JsonHelpers {
    static func prettyPrintedString(from dictionary: [AnyHashable: Any]?) -> String {
        let dictionary = dictionary ?? [:]
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            return "\(dictionary)"
        }
        return prettyPrintedString(
            from: try? JSONSerialization.data(withJSONObject: dictionary)
        )
    }

    static func prettyPrintedString(from data: Data?) -> String {
        let emptyData = "{\n\n}"
        guard let data = data else { return emptyData }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            return String(data: prettyData, encoding: .utf8) ?? emptyData
        } catch {
            return String(data: data, encoding: .utf8) ?? emptyData
        }
    }
}
