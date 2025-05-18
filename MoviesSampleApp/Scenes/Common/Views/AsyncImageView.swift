//
//  AsyncImageView.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

import UIKit

final class AsyncImageView: UIImageView {
    // MARK: - Properties
    private let iconSize: CGSize
    private let networkProvider: NetworkProviderProtocol
    private var task: Task<Void, Never>?

    private lazy var customViews = [loadingView, iconView]

    // MARK: - Views
    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Life cycle
    init(iconSize: CGSize, networkProvider: NetworkProviderProtocol = NetworkProvider()) {
        self.iconSize = iconSize
        self.networkProvider = networkProvider
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    func startLoading() {
        task?.cancel()
        task = nil
        updateMainView(with: loadingView)
        loadingView.startAnimating()
    }

    func startDownload(url: String) {
        startLoading()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let request = NetworkRequest(endpoint: url)
                let response = try await self.networkProvider.makeRequest(request)
                let uiImage = UIImage(data: response.content)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    iconView.image = uiImage
                    updateMainView(with: iconView)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    iconView.image = UIImage(systemName: "photo.circle")
                    iconView.tintColor = .systemGray
                    updateMainView(with: iconView)
                }
            }
        }
    }

    private func updateMainView(with view: UIView?) {
        guard let view = view else { return }
        customViews.forEach { view in
            view.isHidden = true
        }
        UIView.transition(
            with: view, duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                view.isHidden = false
            }
        )
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - ViewCodeProtocol
extension AsyncImageView: ViewCodeProtocol {
    func setupHierarchy() {
        addSubview(loadingView)
        addSubview(iconView)
    }

    func setupConstraints() {
        widthAnchor.constraint(equalToConstant: iconSize.width).isActive = true

        let heightConstraint = heightAnchor.constraint(equalToConstant: iconSize.height)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        customViews.forEach { view in
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: iconSize.width),
                view.heightAnchor.constraint(equalToConstant: iconSize.height)
            ])
        }
    }
}
