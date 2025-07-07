//
//  FavoriteListPresenter.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 07/07/25.
//

protocol FavoriteListPresenterProtocol {
    func presentData(_ data: [MovieDetailsRemoteModel])
    func presentLoading()
}

final class FavoriteListPresenter {
    weak var view: FavoriteListViewProtocol?
}

// MARK: - FavoriteListPresenterProtocol
extension FavoriteListPresenter: FavoriteListPresenterProtocol {
    func presentData(_ data: [MovieDetailsRemoteModel]) {
        let data: [MovieViewState] = data.map { movie in
            MovieViewState.success(
                cacheToViewModel(movie)
            )
        }
        view?.displayData(data)
    }

    func presentLoading() {
        view?.displayData([.loading])
    }
}

private extension FavoriteListPresenter {
    // MARK: - Constants
    enum Constants {
        static let dateFormat = "yyyy-MM-dd"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/h100"
    }

    // MARK: - Helpers
    func cacheToViewModel(_ movie: MovieDetailsRemoteModel) -> MovieViewModel {
        let date = movie.releaseDate.toDate(format: Constants.dateFormat)
        return MovieViewModel(
            id: movie.id,
            title: movie.title,
            releaseDate: date.formatted(date: .numeric, time: .omitted),
            poster: Constants.imageBaseUrl + (movie.backdropPath ?? movie.posterPath),
            score: movie.voteAverage,
            originalLanguage: movie.originalLanguage ?? String()
        )
    }
}
