//
//  MovieListPresenter.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

protocol MovieListPresenterProtocol {
    func presentData(movieList: [MovieRemoteModel])
    func presentSearch(resultList: [MovieRemoteModel])
    func presentLoading()
    func presentFetchError()
    func presentInternetError()
}

final class MovieListPresenter {
    weak var view: MovieListViewProtocol?
}

// MARK: - MovieListPresenterProtocol
extension MovieListPresenter: MovieListPresenterProtocol {
    func presentData(movieList: [MovieRemoteModel]) {
        let data: [MovieViewState] = movieList.map { movie in
            MovieViewState.success(
                remoteToViewModel(movie)
            )
        }
        view?.displayData(data)
    }

    func presentSearch(resultList: [MovieRemoteModel]) {
        let data: [MovieViewState] = resultList.map { movie in
            MovieViewState.success(
                remoteToViewModel(movie)
            )
        }
        view?.resetData()
        view?.displayData(data)
    }

    func presentLoading() {
        view?.displayData([.loading])
    }

    func presentFetchError() {
        view?.displayError()
    }

    func presentInternetError() {
        view?.displayInternetError()
    }
}

private extension MovieListPresenter {
    // MARK: - Constants
    enum Constants {
        static let dateFormat = "yyyy-MM-dd"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/h100"
    }

    // MARK: - Helpers
    func remoteToViewModel(_ movie: MovieRemoteModel) -> MovieViewModel {
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
