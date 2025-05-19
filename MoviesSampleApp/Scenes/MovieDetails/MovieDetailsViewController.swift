//
//  MovieDetailsViewController.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

protocol MovieDetailsViewProtocol: UIViewController {
    func displayData(movieDetails: MovieDetailsViewModel)
    func displayError()
    func displayInternetError()
}

final class MovieDetailsViewController: UIViewController {
    // MARK: - Properties
    private let interactor: MovieDetailsInteractorProtocol
    private let router: MovieDetailsRouterProtocol

    // MARK: - Views
    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var customView: MovieDetailsView = {
        let view = MovieDetailsView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Life cycle
    init(interactor: MovieDetailsInteractorProtocol, router: MovieDetailsRouterProtocol) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.fetchData()
    }
}

// MARK: - ViewCodeProtocol
extension MovieDetailsViewController: ViewCodeProtocol {
    func setupHierarchy() {
        view.addSubview(loadingView)
        view.addSubview(customView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

                customView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: Spacing.x16.value
                ),
                customView.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: Spacing.x16.value
                ),
                customView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -Spacing.x16.value
                ),
                customView.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -Spacing.x16.value
                )
            ]
        )
    }

    func setupConfigurations() {
        view.backgroundColor = .secondarySystemBackground
        loadingView.startAnimating()
    }
}

// MARK: - MovieDetailsViewProtocol
extension MovieDetailsViewController: MovieDetailsViewProtocol {
    func displayData(movieDetails: MovieDetailsViewModel) {
        loadingView.isHidden = true
        customView.isHidden = false
        title = movieDetails.title
        customView.setup(movieDetails)
    }

    func displayError() {
        let alert = makeAlertView(
            title: Localizable.errorAlertTitle.localized,
            buttonTitle: Localizable.retryButtonTitle.localized
        ) { [weak self] in
            self?.interactor.fetchData()
        }
        router.present(alert)
    }

    func displayInternetError() {
        let alert = makeAlertView(
            title: Localizable.internetErrorTitle.localized,
            description: Localizable.internetErrorMessage.localized,
            buttonTitle: Localizable.retryButtonTitle.localized
        ) { [weak self] in
            self?.interactor.fetchData()
        }
        router.present(alert)
    }
}
