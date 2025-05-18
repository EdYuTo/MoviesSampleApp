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
        let router = MovieListRouter(networkProvider: networkProvider)
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
}
