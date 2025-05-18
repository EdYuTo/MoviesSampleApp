//
//  Dictionary+extensions.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

extension Dictionary {
    func toNSDictionary() -> NSDictionary {
        return NSDictionary(dictionary: self)
    }
}
