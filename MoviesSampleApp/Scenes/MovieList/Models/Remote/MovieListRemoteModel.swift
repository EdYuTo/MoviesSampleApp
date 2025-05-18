//
//  MovieListRemoteModel.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

struct MovieListRemoteModel: Decodable {
    let page: Int
    let results: [MovieRemoteModel]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
