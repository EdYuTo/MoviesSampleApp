//
//  MovieListInteractor.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import Foundation
import NetworkProvider

protocol MovieListInteractorProtocol {
    func fetchData()
    func debouncedSearch(_ text: String)
    func immediateSearch(_ text: String)
}

final class MovieListInteractor {
    private let presenter: MovieListPresenterProtocol
    private let networkProvider: NetworkProviderProtocol
    private var currentPage = 1
    private var isLoading = false
    private var data = [MovieRemoteModel]()
    private var searchTask: Task<Void, Never>?
    private let debounceTime: Double

    init(presenter: MovieListPresenterProtocol, networkProvider: NetworkProviderProtocol, debounceTime: Double = 0.5) {
        self.presenter = presenter
        self.networkProvider = networkProvider
        self.debounceTime = debounceTime
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

private extension MovieListInteractor {
    // MARK: - Constants
    enum Constants {
        static let firstPage = 1
        static let secondsInNano = 1_000_000_000.0
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
