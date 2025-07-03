//
//  MoviesSampleApp.swift
//  MoviesSampleApp
//
//  Created on 05/15/2025.
//

import SwiftUI

@main
final class MoviesSampleApp: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let networkProvider = NetworkProvider(session: AuthorizedURLSession.shared)
        let cacheProvider = CacheProvider(storagePath: cacheDirectory())
        let router = MovieListRouter(networkProvider: networkProvider, cacheProvider: cacheProvider)
        let initialViewController = router.start()
        let navigationController = UINavigationController(rootViewController: initialViewController)

        #if DEBUG
        URLProtocol.registerClass(NetworkDebugLogger.self)
        #endif

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "/dev/null")
    }
}
