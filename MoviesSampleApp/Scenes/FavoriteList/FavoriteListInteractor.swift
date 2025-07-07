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
    private var data: [Int: MovieDetailsRemoteModel] = [:]
    private var searchTask: Task<Void, Never>?
    private let debounceTime: Double
    private var searchedText = String()

    init(presenter: FavoriteListPresenterProtocol, cacheProvider: CacheProviderProtocol, debounceTime: Double = 0.5) {
        self.presenter = presenter
        self.cacheProvider = cacheProvider
        self.debounceTime = debounceTime

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFavoriteList),
            name: .movieFavorited,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - FavoriteListInteractorProtocol
extension FavoriteListInteractor: FavoriteListInteractorProtocol {
    func fetchData() {
        presenter.presentLoading()
        Task { [weak self] in
            guard let self else { return }
            let favoritesId = await favoriteList()
            data = data.filter { favoritesId.contains($0.key) }
            for id in favoritesId where data[id] == nil {
                data[id] = try? await self.cacheProvider.get(key: id)
            }
            await MainActor.run {
                if self.searchedText.isEmpty {
                    self.presenter.presentData(Array(self.data.values))
                } else {
                    self.immediateSearch(self.searchedText)
                }
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
        searchedText = text
        guard !text.isEmpty else {
            presenter.presentData(Array(data.values))
            return
        }
        let resultList = data.values.filter { movie in
            movie.title.lowercased().contains(text.lowercased())
        }
        presenter.presentData(resultList)
    }

    func favoriteList() async -> Set<Int> {
        (try? await cacheProvider.get(key: "favoriteList")) ?? []
    }

    @objc
    func updateFavoriteList(_ notification: Notification) {
        fetchData()
    }
}
