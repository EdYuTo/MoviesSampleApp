//
//  MoviesSampleApp.swift
//  MoviesSampleApp
//
//  Created on 05/15/2025.
//

import CacheProvider
import NetworkProvider
import SwiftUI

@main
final class MoviesSampleApp: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let networkProvider = NetworkProvider(session: AuthorizedURLSession.shared)
        let networkDebugDecorator = NetworkDebugDecorator(provider: networkProvider)

        let cacheProvider = CacheProvider(storagePath: cacheDirectory())
        let cacheDebugDecorator = CacheDebugDecorator(provider: cacheProvider)

        let movieListRouter = MovieListRouter(
            networkProvider: networkDebugDecorator,
            cacheProvider: cacheDebugDecorator
        )
        let favoriteListRouter = FavoriteListRouter(
            networkProvider: networkDebugDecorator,
            cacheProvider: cacheDebugDecorator
        )

        let tabController = UITabBarController(nibName: nil, bundle: nil)
        tabController.viewControllers = [movieListRouter.start(), favoriteListRouter.start()]


        let navigationController = UINavigationController(rootViewController: tabController)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    private func cacheDirectory() -> URL {
        let defaultUrl = URL(fileURLWithPath: "/dev/null")
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
              let bundleId = Bundle.main.bundleIdentifier else {
            return defaultUrl
        }
        do {
            let directory = url
                .appendingPathComponent(bundleId)
                .appendingPathComponent("Application")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            return directory
        } catch {
            return defaultUrl
        }
    }
}
