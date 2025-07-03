//
//  MovieDetailsInteractor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation

protocol MovieDetailsInteractorProtocol {
    func fetchData()
    func toggleFavorite()
}

final class MovieDetailsInteractor {
    private let presenter: MovieDetailsPresenterProtocol
    private let networkProvider: NetworkProviderProtocol
    private let cacheProvider: CacheProviderProtocol
    private let id: Int

    init(
        presenter: MovieDetailsPresenterProtocol,
        networkProvider: NetworkProviderProtocol,
        cacheProvider: CacheProviderProtocol,
        id: Int
    ) {
        self.presenter = presenter
        self.networkProvider = networkProvider
        self.cacheProvider = cacheProvider
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
                let isFavorite = await isFavorite()
                await MainActor.run {
                    presenter.presentData(movieDetails: response.content, isFavorite: isFavorite)
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

    func toggleFavorite() {
        Task { @MainActor in
            var favoriteList = await favoriteList()
            if favoriteList.contains(id) {
                favoriteList.remove(id)
                presenter.presentUnfavorite()
            } else {
                favoriteList.insert(id)
                presenter.presentFavorite()
            }
            try? await cacheProvider.set(key: "favoriteList", value: favoriteList)
        }
    }
}

// MARK: - Helpers
private extension MovieDetailsInteractor {
    func movieDetailsRequest(id: Int, locale: String) -> NetworkRequest {
        NetworkRequest(
            endpoint: "https://api.themoviedb.org/3/movie/\(id)",
            queryParams: ["language": locale]
        )
    }

    func favoriteList() async -> Set<Int> {
        (try? await cacheProvider.get(key: "favoriteList")) ?? []
    }

    func isFavorite() async -> Bool {
        await favoriteList().contains(id)
    }
}
