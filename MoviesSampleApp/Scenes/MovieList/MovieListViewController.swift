//
//  MovieListViewController.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

protocol MovieListViewProtocol: UIViewController {
    func displayData(_ movieStateList: [MovieViewState])
    func displayError()
    func displayInternetError()
}

final class MovieListViewController: UIViewController {
    // MARK: - Properties
    private let interactor: MovieListInteractorProtocol
    private let router: MovieListRouterProtocol
    private var dataSource = [MovieViewState]()

    // MARK: - Views
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MovieListCell.self, forCellReuseIdentifier: MovieListCell.reuseIdentifier)
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.reuseIdentifier)
        tableView.register(ErrorTableViewCell.self, forCellReuseIdentifier: ErrorTableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Life cycle
    init(interactor: MovieListInteractorProtocol, router: MovieListRouterProtocol) {
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
extension MovieListViewController: ViewCodeProtocol {
    func setupHierarchy() {
        view.addSubview(tableView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupConfigurations() {
        title = Localizable.movieListTitle.localized
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dataSource.count {
            switch dataSource[indexPath.row] {
            case let .success(model):
                return dequeueMovieCell(tableView, indexPath, model)
            case .loading:
                interactor.fetchData()
                return dequeueLoadingCell(tableView, indexPath)
            case .error:
                return dequeueErrorCell(tableView, indexPath)
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < dataSource.count else {
            return
        }
        switch dataSource[indexPath.row] {
        case let .success(model):
            router.openDetails(id: model.id)
        case .error:
            replaceLastState(with: .loading)
            interactor.fetchData()
        default:
            break
        }
    }

    private func dequeueMovieCell(
        _ tableView: UITableView,
        _ indexPath: IndexPath,
        _ model: MovieViewModel
    ) -> UITableViewCell {
        guard let viewCell = tableView.dequeueReusableCell(
            withIdentifier: MovieListCell.reuseIdentifier,
            for: indexPath
        ) as? MovieListCell else {
            return UITableViewCell()
        }
        viewCell.setup(model)
        return viewCell
    }

    func dequeueLoadingCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LoadingTableViewCell.reuseIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none
        return cell
    }

    func dequeueErrorCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(
            withIdentifier: ErrorTableViewCell.reuseIdentifier,
            for: indexPath
        )
    }
}

// MARK: - MovieListViewProtocol
extension MovieListViewController: MovieListViewProtocol {
    func displayData(_ movieStateList: [MovieViewState]) {
        let size = dataSource.count
        _ = dataSource.popLast()
        dataSource.append(contentsOf: movieStateList)
        if size == 0 {
            tableView.reloadData()
        } else {
            let loadingIndex = IndexPath(row: size-1, section: .zero)
            let newRows = (size-1..<dataSource.count).map { row in
                IndexPath(row: row, section: 0)
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [loadingIndex], with: .fade)
            tableView.insertRows(at: newRows, with: .fade)
            tableView.endUpdates()
        }
    }

    func displayError() {
        if dataSource.count == 0 {
            let alert = makeAlertView(
                title: Localizable.errorAlertTitle.localized,
                buttonTitle: Localizable.retryButtonTitle.localized
            ) { [weak self] in
                self?.interactor.fetchData()
            }
            router.present(alert)
        } else {
            replaceLastState(with: .error)
        }
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

    private func replaceLastState(with model: MovieViewState) {
        _ = dataSource.popLast()
        dataSource.append(model)
        let lastIndex = IndexPath(row: dataSource.count-1, section: .zero)
        tableView.reloadRows(at: [lastIndex], with: .fade)
    }
}
