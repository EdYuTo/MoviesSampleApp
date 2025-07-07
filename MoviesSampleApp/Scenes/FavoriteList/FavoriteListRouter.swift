//
//  FavoriteListRouter.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 07/07/25.
//

import CacheProvider
import NetworkProvider
import UIKit

protocol FavoriteListRouterProtocol {
    func openDetails(id: Int)
}

final class FavoriteListRouter {
    private let networkProvider: NetworkProviderProtocol
    private let cacheProvider: CacheProviderProtocol
    private weak var view: FavoriteListViewProtocol?

    init(
        networkProvider: NetworkProviderProtocol,
        cacheProvider: CacheProviderProtocol,
        view: FavoriteListViewProtocol? = nil
    ) {
        self.networkProvider = networkProvider
        self.cacheProvider = cacheProvider
        self.view = view
    }

    func start() -> UIViewController {
        let presenter = FavoriteListPresenter()
        let interactor = FavoriteListInteractor(presenter: presenter, cacheProvider: cacheProvider)
        let viewController = FavoriteListViewController(interactor: interactor, router: self)
        presenter.view = viewController
        view = viewController
        return viewController
    }
}

// MARK: - FavoriteListRouterProtocol
extension FavoriteListRouter: FavoriteListRouterProtocol {
    func openDetails(id: Int) {
        let detailsRouter = MovieDetailsRouter(id: id, networkProvider: networkProvider, cacheProvider: cacheProvider)
        let detailsViewController = detailsRouter.start()
        let navigationController = UINavigationController(rootViewController: detailsViewController)
        view?.navigationController?.present(navigationController, animated: true)
    }
}
