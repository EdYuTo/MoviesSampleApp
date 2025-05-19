//
//  MovieDetailsRouter.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

protocol MovieDetailsRouterProtocol {
    func present(_ viewController: UIViewController)
}

final class MovieDetailsRouter {
    private let id: Int
    private let networkProvider: NetworkProviderProtocol
    private weak var view: MovieDetailsViewProtocol?

    init(id: Int, networkProvider: NetworkProviderProtocol, view: MovieDetailsViewProtocol? = nil) {
        self.id = id
        self.networkProvider = networkProvider
        self.view = view
    }

    func start() -> UIViewController {
        let presenter = MovieDetailsPresenter()
        let interactor = MovieDetailsInteractor(
            presenter: presenter,
            networkProvider: networkProvider,
            id: id
        )
        let viewController = MovieDetailsViewController(interactor: interactor, router: self)
        presenter.view = viewController
        view = viewController
        return viewController
    }
}

// MARK: - MovieDetailsRouterProtocol
extension MovieDetailsRouter: MovieDetailsRouterProtocol {
    func present(_ viewController: UIViewController) {
        view?.navigationController?.present(viewController, animated: true)
    }
}
