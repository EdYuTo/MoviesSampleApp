//
//  ErrorTableViewCell.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

final class ErrorTableViewCell: UITableViewCell, IdentifiableCell {
    // MARK: - Views
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle(Localizable.retryButtonTitle.localized, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ViewCodeProtocol
extension ErrorTableViewCell: ViewCodeProtocol {
    func setupHierarchy() {
        addSubview(button)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
