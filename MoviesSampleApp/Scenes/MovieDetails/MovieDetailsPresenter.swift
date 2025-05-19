//
//  MovieDetailsPresenter.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

protocol MovieDetailsPresenterProtocol {
    func presentData(movieDetails: MovieDetailsRemoteModel)
    func presentFetchError()
    func presentInternetError()
}

final class MovieDetailsPresenter {
    weak var view: MovieDetailsViewProtocol?
}

// MARK: - MovieDetailsPresenterProtocol
extension MovieDetailsPresenter: MovieDetailsPresenterProtocol {
    func presentData(movieDetails: MovieDetailsRemoteModel) {
        let date = movieDetails.releaseDate.toDate(format: Constants.dateFormat)
        let viewModel = MovieDetailsViewModel(
            title: movieDetails.title,
            releaseDate: date.formatted(date: .numeric, time: .omitted),
            genres: movieDetails.genres.map { $0.name }.joined(separator: ", "),
            rating: "\(movieDetails.voteAverage) (\(movieDetails.voteCount) votes)",
            overview: movieDetails.overview,
            image: Constants.imageBaseUrl + (movieDetails.backdropPath ?? movieDetails.posterPath)
        )
        view?.displayData(movieDetails: viewModel)
    }

    func presentFetchError() {
        view?.displayError()
    }

    func presentInternetError() {
        view?.displayInternetError()
    }
}

fileprivate extension MovieDetailsPresenter {
    // MARK: - Constants
    enum Constants {
        static let dateFormat = "yyyy-MM-dd"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/original"
    }
}
