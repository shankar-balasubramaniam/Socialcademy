//
//  Loadable.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import Foundation

enum Loadable<Value> {
    case loading
    case error(Error)
    case loaded(Value)
}

extension Loadable where Value: RangeReplaceableCollection {
    static var empty: Loadable<Value> { .loaded(Value()) }
    
    var value: Value? {
        get {
            if case let .loaded(value) = self {
                return value
            }
            return nil
        }
        
        set {
            guard let newValue = newValue else { return }
            self = .loaded(newValue)
        }
    }
}

extension Loadable: Equatable where Value: Equatable {
    static func == (lhs: Loadable<Value>, rhs: Loadable<Value>) -> Bool {
        switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.error(let error1), .error(let error2)):
                return error1.localizedDescription == error2.localizedDescription
            case (.loaded(let value1), .loaded(let value2)):
                return value1 == value2
            default:
                return false
        }
    }
}

#if DEBUG
extension Loadable {
    static var error: Loadable<Value> { .error(PreviewError()) }
    
    private struct PreviewError: LocalizedError {
        var errorDescription: String? = "Lorem ipsum dolor sit amet."
    }
    
    func simulate() async throws -> Value {
        switch self {
        case .loading:
            try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            fatalError("Timeout exceeded for \"loading\" case preview")
        case .error(let error):
            throw error
        case .loaded(let value):
            return value
        }
    }
}
#endif
