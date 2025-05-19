//
//  MovieListInteractor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

protocol MovieListInteractorProtocol {
    func fetchData()
}

final class MovieListInteractor {
    private let presenter: MovieListPresenterProtocol
    private let networkProvider: NetworkProviderProtocol
    private var currentPage = 1
    private var isLoading = false

    init(presenter: MovieListPresenterProtocol, networkProvider: NetworkProviderProtocol) {
        self.presenter = presenter
        self.networkProvider = networkProvider
    }
}

// MARK: - MovieListInteractorProtocol
extension MovieListInteractor: MovieListInteractorProtocol {
    func fetchData() {
        guard !isLoading else { return }
        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let local = Locale.customLanguageCode
                let request = movieListRequest(page: currentPage, locale: local)
                let response: NetworkResponse<MovieListRemoteModel> = try await networkProvider.makeRequest(request)
                await MainActor.run {
                    self.presenter.presentData(movieList: response.content)
                    self.currentPage += 1
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    if let error = error as? NetworkError, case .connectionError = error {
                        self.presenter.presentInternetError()
                    } else {
                        self.presenter.presentFetchError()
                    }
                    self.isLoading = false
                }
            }
        }
    }
}

fileprivate extension MovieListInteractor {
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
}
