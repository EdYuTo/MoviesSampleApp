//
//  MovieListRouter.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

protocol MovieListRouterProtocol {
    func openDetails(id: Int)
    func present(_ viewController: UIViewController)
}

final class MovieListRouter {
    private let networkProvider: NetworkProviderProcotol
    private weak var view: MovieListViewProtocol?

    init(networkProvider: NetworkProviderProcotol, view: MovieListViewProtocol? = nil) {
        self.networkProvider = networkProvider
        self.view = view
    }

    func start() -> UIViewController {
        let presenter = MovieListPresenter()
        let interactor = MovieListInteractor(presenter: presenter, networkProvider: networkProvider)
        let viewController = MovieListViewController(interactor: interactor, router: self)
        presenter.view = viewController
        view = viewController
        return viewController
    }
}

// MARK: - MovieListRouterProtocol
extension MovieListRouter: MovieListRouterProtocol {
    func openDetails(id: Int) {
        let detailsViewController = UIViewController()
        view?.navigationController?.present(detailsViewController, animated: true)
    }

    func present(_ viewController: UIViewController) {
        view?.navigationController?.present(viewController, animated: true)
    }
}
