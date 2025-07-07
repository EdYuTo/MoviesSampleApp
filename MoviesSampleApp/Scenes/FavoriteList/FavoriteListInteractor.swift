//
//  FavoriteListInteractor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 07/07/25.
//

import CacheProvider
import Foundation

protocol FavoriteListInteractorProtocol {
    func fetchData()
    func debouncedSearch(_ text: String)
    func immediateSearch(_ text: String)
}

final class FavoriteListInteractor {
    private let presenter: FavoriteListPresenterProtocol
    private let cacheProvider: CacheProviderProtocol
    private var data = [MovieDetailsRemoteModel]()
    private var searchTask: Task<Void, Never>?
    private let debounceTime: Double

    init(presenter: FavoriteListPresenterProtocol, cacheProvider: CacheProviderProtocol, debounceTime: Double = 0.5) {
        self.presenter = presenter
        self.cacheProvider = cacheProvider
        self.debounceTime = debounceTime
    }
}

// MARK: - FavoriteListInteractorProtocol
extension FavoriteListInteractor: FavoriteListInteractorProtocol {
    func fetchData() {
        presenter.presentLoading()
        Task { [weak self] in
            guard let self else { return }
            let favoritesId = await favoriteList()
            var favoritesList = [MovieDetailsRemoteModel?]()
            for id in favoritesId {
                favoritesList.append(try? await self.cacheProvider.get(key: id))
            }
            data = favoritesList.compactMap({ $0 })
            await MainActor.run {
                self.presenter.presentData(self.data)
            }
        }
    }

    func immediateSearch(_ text: String) {
        searchTask?.cancel()
        searchTask = nil
        search(text)
    }

    func debouncedSearch(_ text: String) {
        searchTask?.cancel()
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let debounceTime = UInt64(debounceTime * Constants.secondsInNano)
                try await Task.sleep(nanoseconds: debounceTime)
                try Task.checkCancellation()
                search(text)
            } catch {
                return
            }
        }
    }
}

private extension FavoriteListInteractor {
    // MARK: - Constants
    enum Constants {
        static let secondsInNano = 1_000_000_000.0
    }

    // MARK: - Helpers
    func search(_ text: String) {
        guard !text.isEmpty else {
            presenter.presentData(data)
            return
        }
        let resultList = data.filter { movie in
            movie.title.lowercased().contains(text.lowercased())
        }
        presenter.presentData(resultList)
    }

    func favoriteList() async -> Set<Int> {
        (try? await cacheProvider.get(key: "favoriteList")) ?? []
    }
}
