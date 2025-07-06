//
//  MovieTableViewCellController.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 04/07/25.
//

import UIKit

enum MovieTableViewCellController {
    static func register(_ tableView: UITableView) {
        tableView.register(MovieListCell.self, forCellReuseIdentifier: MovieListCell.reuseIdentifier)
        tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.reuseIdentifier)
        tableView.register(ErrorTableViewCell.self, forCellReuseIdentifier: ErrorTableViewCell.reuseIdentifier)
    }

    static func dequeue(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath,
        withItem item: MovieViewState
    ) -> UITableViewCell {
        switch item {
        case let .success(model):
            return dequeueMovieCell(tableView, indexPath, model)
        case .loading:
            return dequeueLoadingCell(tableView, indexPath)
        case .error:
            return dequeueErrorCell(tableView, indexPath)
        }
    }
}

// MARK: - Helpers
private extension MovieTableViewCellController {
    static func dequeueMovieCell(
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

    static func dequeueLoadingCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: LoadingTableViewCell.reuseIdentifier,
            for: indexPath
        )
        cell.selectionStyle = .none
        return cell
    }

    static func dequeueErrorCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(
            withIdentifier: ErrorTableViewCell.reuseIdentifier,
            for: indexPath
        )
    }
}
