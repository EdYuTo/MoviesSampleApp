//
//  MovieDetailsInteractor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

protocol MovieDetailsInteractorProtocol {
    func fetchData()
}

final class MovieDetailsInteractor {
    private let presenter: MovieDetailsPresenterProtocol
    private let networkProvider: NetworkProviderProtocol
    private let id: Int

    init(
        presenter: MovieDetailsPresenterProtocol,
        networkProvider: NetworkProviderProtocol,
        id: Int
    ) {
        self.presenter = presenter
        self.networkProvider = networkProvider
        self.id = id
    }
}

// MARK: - MovieDetailsInteractorProtocol
extension MovieDetailsInteractor: MovieDetailsInteractorProtocol {
    func fetchData() {
        Task {
            do {
                let local = Locale.customLanguageCode
                let request = movieDetailsRequest(id: id, locale: local)
                let response: NetworkResponse<MovieDetailsRemoteModel> = try await networkProvider.makeRequest(request)
                await MainActor.run {
                    presenter.presentData(movieDetails: response.content)
                }
            } catch {
                await MainActor.run {
                    if let error = error as? NetworkError, case .connectionError = error {
                        presenter.presentInternetError()
                    } else {
                        presenter.presentFetchError()
                    }
                }
            }
        }
    }
}

fileprivate extension MovieDetailsInteractor {
    // MARK: - Helpers
    func movieDetailsRequest(id: Int, locale: String) -> NetworkRequest {
        NetworkRequest(
            endpoint: "https://api.themoviedb.org/3/movie/\(id)",
            queryParams: ["language": locale]
        )
    }
}
