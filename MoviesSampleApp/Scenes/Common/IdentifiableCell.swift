//
//  IdentifiableCell.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

protocol IdentifiableCell {}

extension IdentifiableCell {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}
