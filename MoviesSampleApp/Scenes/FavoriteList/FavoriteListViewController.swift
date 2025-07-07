//
//  FavoriteListViewController.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 07/07/25.
//

import UIKit

protocol FavoriteListViewProtocol: UIViewController {
    func displayData(_ movieStateList: [MovieViewState])
}

final class FavoriteListViewController: UIViewController {
    // MARK: - Properties
    private typealias DataSource = UITableViewDiffableDataSource<Int, MovieViewState>

    private let interactor: FavoriteListInteractorProtocol
    private let router: FavoriteListRouterProtocol

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
    init(interactor: FavoriteListInteractorProtocol, router: FavoriteListRouterProtocol) {
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
extension FavoriteListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        interactor.immediateSearch(textField.text ?? String())
        searchBar.resignFirstResponder()
        return true
    }
}

// MARK: - UISearchBarDelegate
extension FavoriteListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor.debouncedSearch(searchText)
    }
}

// MARK: - ViewCodeProtocol
extension FavoriteListViewController: ViewCodeProtocol {
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
        title = Localizable.favoriteListTitle.localized
        tableView.dataSource = dataSource
        var snapshot = NSDiffableDataSourceSnapshot<Int, MovieViewState>()
        snapshot.appendSections([0])
        snapshot.appendItems([.loading])
        dataSource.apply(snapshot, animatingDifferences: false)
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: "heart.circle"),
            selectedImage: UIImage(systemName: "heart.circle.fill")
        )
    }
}

// MARK: - UITableViewDelegate
extension FavoriteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch model {
        case let .success(model):
            router.openDetails(id: model.id)
        default:
            break
        }
    }
}

// MARK: - FavoriteListViewProtocol
extension FavoriteListViewController: FavoriteListViewProtocol {
    func displayData(_ movieStateList: [MovieViewState]) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(movieStateList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
