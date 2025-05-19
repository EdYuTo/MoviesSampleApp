//
//  AsyncImageView.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 17/05/25.
//

import UIKit

final class AsyncImageView: UIImageView {
    // MARK: - Properties
    private let networkProvider: NetworkProviderProtocol
    private var task: Task<Void, Never>?

    // MARK: - Views
    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Life cycle
    init(networkProvider: NetworkProviderProtocol = NetworkProvider()) {
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
        animate { [weak self] in
            guard let self else { return }
            loadingView.isHidden = false
            loadingView.startAnimating()
            image = nil
        }
    }

    func startDownload(url: String) {
        startLoading()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let request = NetworkRequest(endpoint: url)
                let response = try await self.networkProvider.makeRequest(request)
                let uiImage = UIImage(data: response.content)
                await MainActor.run {
                    self.animate {
                        self.loadingView.isHidden = true
                        self.image = uiImage
                    }
                }
            } catch {
                await MainActor.run {
                    self.tintColor = .systemGray
                    self.animate {
                        self.loadingView.isHidden = true
                        self.image = UIImage(systemName: "photo.circle")
                    }
                }
            }
        }
    }

    private func animate(with animation: @escaping () -> Void) {
        UIView.transition(
            with: self, duration: 0.5,
            options: .transitionCrossDissolve,
            animations: animation
        )
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - ViewCodeProtocol
extension AsyncImageView: ViewCodeProtocol {
    func setupHierarchy() {
        addSubview(loadingView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
