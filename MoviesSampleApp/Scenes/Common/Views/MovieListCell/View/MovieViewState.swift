//
//  MovieViewState.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

enum MovieViewState {
    case loading
    case success(MovieViewModel)
    case error
}

extension MovieViewState: Equatable {
    static func == (lhs: MovieViewState, rhs: MovieViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.error, .error):
            return true
        case let(.success(lhsValue), .success(rhsValue)):
            return lhsValue.id == rhsValue.id
        default:
            return false
        }
    }
}

extension MovieViewState: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .loading:
            hasher.combine("loading")
        case let .success(model):
            hasher.combine(model.id)
        case .error:
            hasher.combine("error")
        }
    }
}
