//
//  MovieListViewController.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

protocol MovieListViewProtocol: UIViewController {
    func displayData(_ movieStateList: [MovieViewState])
    func resetData()
    func displayError()
    func displayInternetError()
}

final class MovieListViewController: UIViewController {
    // MARK: - Properties
    private typealias DataSource = UITableViewDiffableDataSource<Int, MovieViewState>

    private let interactor: MovieListInteractorProtocol
    private let router: MovieListRouterProtocol

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            MovieTableViewCellController.dequeue(tableView, cellForRowAt: indexPath, withItem: item)
        }
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }()

    // MARK: - Views
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.delegate = self
            textField.enablesReturnKeyAutomatically = false
        }
        return searchBar
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        MovieTableViewCellController.register(tableView)
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

// MARK: - UITextFieldDelegate
extension MovieListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        interactor.immediateSearch(textField.text ?? String())
        searchBar.resignFirstResponder()
        return true
    }
}

// MARK: - UISearchBarDelegate
extension MovieListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor.debouncedSearch(searchText)
    }
}

// MARK: - ViewCodeProtocol
extension MovieListViewController: ViewCodeProtocol {
    func setupHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupConfigurations() {
        title = Localizable.movieListTitle.localized
        tableView.dataSource = dataSource
        var snapshot = NSDiffableDataSourceSnapshot<Int, MovieViewState>()
        snapshot.appendSections([0])
        snapshot.appendItems([.loading])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UITableViewDelegate
extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch model {
        case let .success(model):
            router.openDetails(id: model.id)
        case .error:
            displayData([.loading])
            interactor.fetchData()
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let model = dataSource.itemIdentifier(for: indexPath), model == .loading {
            interactor.fetchData()
        }
    }
}

// MARK: - MovieListViewProtocol
extension MovieListViewController: MovieListViewProtocol {
    func displayData(_ movieStateList: [MovieViewState]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([.error, .loading])
        snapshot.appendItems(movieStateList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func resetData() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func displayError() {
        let firstItem = dataSource.itemIdentifier(for: .init(row: 0, section: 0))
        if firstItem == nil || firstItem == .error || firstItem == .loading {
            let alert = makeAlertView(
                title: Localizable.errorAlertTitle.localized,
                buttonTitle: Localizable.retryButtonTitle.localized
            ) { [weak self] in
                self?.interactor.fetchData()
            }
            router.present(alert)
        } else {
            displayData([.error])
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
}
