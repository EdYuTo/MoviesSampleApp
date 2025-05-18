//
//  MovieListCell.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

final class MovieListCell: UITableViewCell, IdentifiableCell {
    // MARK: - Properties
    let iconSize = Spacing.x64.value

    // MARK: - Views
    lazy var iconView: AsyncImageView = {
        let view = AsyncImageView(iconSize: CGSize(width: iconSize, height: iconSize))
        view.layer.cornerRadius = iconSize / 2
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var movieTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    lazy var releaseDate: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    lazy var descriptionStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [movieTitle, releaseDate])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconView, descriptionStackView])
        stack.axis = .horizontal
        stack.spacing = iconSize / 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.startLoading()
    }

    // MARK: Methods
    func setup(_ model: MovieViewModel) {
        movieTitle.text = model.title
        releaseDate.text = Localizable.releaseDate.localized(with: model.releaseDate)
        setupView()
        iconView.startDownload(url: model.poster)
    }
}

// MARK: - ViewCodeProtocol
extension MovieListCell: ViewCodeProtocol {
    func setupHierarchy() {
        addSubview(mainStackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.x16.value),
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.x16.value),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.x16.value),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Spacing.x16.value)
        ])
    }
}
