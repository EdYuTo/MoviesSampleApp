//
//  MovieRemoteModel.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

struct MovieRemoteModel: Decodable {
    let adult: Bool
    let backdropPath: String?
    let genreIDS: [Int]?
    let id: Int
    let originalLanguage, originalTitle, overview: String?
    let popularity: Double
    let posterPath, releaseDate, title: String
    let video: Bool?
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
