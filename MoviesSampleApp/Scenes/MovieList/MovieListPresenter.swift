//
//  MovieListPresenter.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

protocol MovieListPresenterProtocol {
    func presentData(movieList: MovieListRemoteModel)
    func presentFetchError()
    func presentInternetError()
}

final class MovieListPresenter {
    weak var view: MovieListViewProtocol?
}

// MARK: - MovieListPresenterProtocol
extension MovieListPresenter: MovieListPresenterProtocol {
    func presentData(movieList: MovieListRemoteModel) {
        var data: [MovieViewState] = movieList.results.map { movie in
            let date = movie.releaseDate.toDate(format: Constants.dateFormat)
            return MovieViewState.success(
                MovieViewModel(
                    id: movie.id,
                    title: movie.title,
                    releaseDate: date.formatted(date: .numeric, time: .omitted),
                    poster: Constants.imageBaseUrl + (movie.backdropPath ?? movie.posterPath),
                    score: movie.voteAverage,
                    originalLanguage: movie.originalLanguage
                )
            )
        }
        if !data.isEmpty {
            data.append(MovieViewState.loading)
        }
        view?.displayData(data)
    }

    func presentFetchError() {
        view?.displayError()
    }

    func presentInternetError() {
        view?.displayInternetError()
    }
}

fileprivate extension MovieListPresenter {
    // MARK: - Constants
    enum Constants {
        static let dateFormat = "yyyy-MM-dd"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/h100"
    }
}
