//
//  MovieDetailsView.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

class MovieDetailsView: UIView {
    // MARK: - Properties
    private let posterHeight = 250.0

    // MARK: - Views
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            posterImageView,
            titleLabel,
            overviewLabel,
            releaseDateLabel,
            genresLabel,
            ratingLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = Spacing.x8.value
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var posterImageView: AsyncImageView = {
        let imageView = AsyncImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()

    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var genresLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Life cycle
    init() {
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Method
    func setup(_ movie: MovieDetailsViewModel) {
        titleLabel.text = movie.title
        releaseDateLabel.attributedText = makeLabel(
            title: Localizable.movieDetailsReleaseDate.localized,
            description: movie.releaseDate
        )
        genresLabel.attributedText = makeLabel(
            title: Localizable.movieDetailsGenres.localized,
            description: movie.genres
        )
        ratingLabel.attributedText = makeLabel(
            title: Localizable.movieDetailsRating.localized,
            description: movie.rating
        )
        overviewLabel.text = movie.overview
        posterImageView.startDownload(url: movie.image)
    }

    private func makeLabel(title: String, description: String) -> NSAttributedString {
        let systemFont = UIFont.preferredFont(forTextStyle: .body)
        let boldFont = UIFont.boldSystemFont(ofSize: systemFont.pointSize)
        let regularFont = UIFont.systemFont(ofSize: systemFont.pointSize)

        let attributed = NSMutableAttributedString(
            string: title,
            attributes: [.font: boldFont]
        )
        let normalAttributed = NSAttributedString(
            string: description,
            attributes: [.font: regularFont]
        )

        attributed.append(normalAttributed)

        return attributed
    }
}

extension MovieDetailsView: ViewCodeProtocol {
    func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            posterImageView.heightAnchor.constraint(equalToConstant: posterHeight),

            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Spacing.x16.value
            ),
            contentStackView.topAnchor.constraint(
                equalTo: scrollView.topAnchor,
                constant: Spacing.x16.value
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -Spacing.x16.value
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor,
                constant: -Spacing.x16.value
            ),
            contentStackView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -Spacing.x32.value
            )
        ])
    }

    // MARK: - Setup
    func setupConfigurations() {
        posterImageView.startLoading()
    }
}
