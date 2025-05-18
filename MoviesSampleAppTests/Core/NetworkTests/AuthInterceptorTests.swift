//
//  AuthInterceptorTests.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

@testable
import MoviesSampleApp
import XCTest

final class AuthInterceptorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolMock.setup()
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolMock.tearDown()
    }

    func testHeaders() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]

        AuthorizedURLSession.defaultSession = URLSession(configuration: configuration)

        let sut = AuthorizedURLSession.shared
        let networkProvider = NetworkProvider(session: sut)
        let request = NetworkRequest(
            endpoint: #file
        )

        _ = try? await networkProvider.makeRequest(request)

        let authorizationHeader = try XCTUnwrap(URLProtocolMock.request?.allHTTPHeaderFields?["Authorization"])
        guard authorizationHeader.count <= 25 else {
            XCTFail("Api access token should not be present in code")
            return
        }
        XCTAssertNotNil(URLProtocolMock.request?.allHTTPHeaderFields?["Accept"])
    }
}
