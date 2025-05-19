//
//  MovieDetailsRemoteModel.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

// MARK: - Welcome
struct MovieDetailsRemoteModel: Codable {
    let adult: Bool
    let backdropPath: String?
    let budget: Int?
    let genres: [Genre]
    let homepage: String?
    let id: Int
    let imdbID: String?
    let originCountry: [String]?
    let originalLanguage, originalTitle: String?
    let overview: String
    let popularity: Double?
    let posterPath: String
    let productionCompanies: [ProductionCompany]
    let releaseDate, title: String
    let revenue, runtime: Int?
    let spokenLanguages: [SpokenLanguage]?
    let status, tagline: String?
    let video: Bool?
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case budget, genres, homepage, id
        case imdbID = "imdb_id"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case releaseDate = "release_date"
        case revenue, runtime
        case spokenLanguages = "spoken_languages"
        case status, tagline, title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}

// MARK: - ProductionCompany
struct ProductionCompany: Codable {
    let id: Int
    let logoPath, name, originCountry: String?

    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

// MARK: - SpokenLanguage
struct SpokenLanguage: Codable {
    let englishName, languageCode, name: String?

    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case languageCode = "iso_639_1"
        case name
    }
}
