//
//  MovieListInteractor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

protocol MovieListInteractorProtocol {
    func fetchData()
    func search(_ text: String)
}

final class MovieListInteractor {
    private let presenter: MovieListPresenterProtocol
    private let networkProvider: NetworkProviderProtocol
    private var currentPage = 1
    private var isLoading = false
    private var data = [MovieRemoteModel]()

    init(presenter: MovieListPresenterProtocol, networkProvider: NetworkProviderProtocol) {
        self.presenter = presenter
        self.networkProvider = networkProvider
    }
}

// MARK: - MovieListInteractorProtocol
extension MovieListInteractor: MovieListInteractorProtocol {
    func fetchData() {
        guard shouldFetchMoreDataIfNotLoading() else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                let local = Locale.customLanguageCode
                let request = movieListRequest(page: currentPage, locale: local)
                let response: NetworkResponse<MovieListRemoteModel> = try await networkProvider.makeRequest(request)
                await MainActor.run {
                    let movieList = response.content.results
                    self.data.append(contentsOf: movieList)
                    self.presenter.presentData(movieList: movieList)
                    self.presenter.presentLoading()
                    self.currentPage += 1
                    self.finishLoading()
                }
            } catch {
                await MainActor.run {
                    if let error = error as? NetworkError, case .connectionError = error {
                        self.presenter.presentInternetError()
                    } else {
                        self.presenter.presentFetchError()
                    }
                    self.finishLoading()
                }
            }
        }
    }

    func search(_ text: String) {
        guard !text.isEmpty else {
            presenter.presentData(movieList: data)
            presenter.presentLoading()
            return
        }
        let resultList = data.filter { movie in
            movie.title.lowercased().contains(text.lowercased())
        }
        presenter.presentSearch(resultList: resultList)
    }
}

private extension MovieListInteractor {
    // MARK: - Constants
    enum Constants {
        static let firstPage = 1
    }

    // MARK: - Helpers
    func movieListRequest(page: Int, locale: String) -> NetworkRequest {
        NetworkRequest(
            endpoint: "https://api.themoviedb.org/3/discover/movie",
            queryParams: [
                "include_adult": "false",
                "include_video": "false",
                "language": locale,
                "page": "\(currentPage)",
                "sort_by": "popularity.desc"
            ]
        )
    }

    func shouldFetchMoreDataIfNotLoading() -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        return true
    }

    func finishLoading() {
        isLoading = false
    }
}
