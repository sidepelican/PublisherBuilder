import Combine
import XCTest
@testable import PublisherBuilder

private let neverSubject = PassthroughSubject<[Int], Never>()
private let errorSubject = PassthroughSubject<[String], Error>()
private struct CustomError: Error {}
private let customErrorSubject = PassthroughSubject<[Double], CustomError>()

final class FlatMapExtensionTests: XCTestCase {
    func testOutputType() {
        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v in
                Just([])
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<Int, Never> = neverSubject
            .flatMapBuild { v -> AnyPublisher<[String], Never> in
                Just([])
            }
            .map(\.count)
            .eraseToAnyPublisher()
    }

    func testErrorType() {
        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v in
                errorSubject
                    .catch { _ in
                        Empty()
                    }
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Error> = neverSubject
            .flatMapBuild { v in
                errorSubject
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[Int], Error> = errorSubject
            .flatMapBuild { v in
                neverSubject
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[Int], Error> = errorSubject
            .flatMapBuild { v -> AnyPublisher<[Int], Never> in
                Empty()
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Error> = errorSubject
            .flatMapBuild { v in
                errorSubject
            }
            .eraseToAnyPublisher()
    }

    func testEither() {
        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v in
                if v.isEmpty {
                    Just([])
                } else {
                    Just([])
                }
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v in
                if v.isEmpty {
                    Just([])
                } else {
                    Just([])
                }
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v in
                if v.isEmpty {
                    Just([])
                } else {
                    errorSubject
                        .catch { _ in
                            Empty()
                        }
                }
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Error> = neverSubject
            .flatMapBuild { v in
                if v.isEmpty {
                    Just([])
                } else {
                    errorSubject
                }
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Error> = errorSubject
            .flatMapBuild { v in
                if v.isEmpty {
                    Just([])
                } else {
                    errorSubject
                }
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], CustomError> = neverSubject
            .flatMapBuild { v in
                if v.isEmpty {
                    Just([])
                } else {
                    Fail(error: CustomError())
                }
            }
            .eraseToAnyPublisher()
    }

    func testMapErrorFlatMap() {
        let _: AnyPublisher<Int, Error> = PassthroughSubject<Bool, CustomError>()
            .flatMapBuild { _ in
                if Bool.random() {
                    Fail(error: CustomError())
                } else {
                    PassthroughSubject<Int, Error>()
                }
            }
            .mapError { _ in CustomError() }
            .eraseToAnyPublisher()

        let _: AnyPublisher<Int, CustomError> = PassthroughSubject<Bool, CustomError>()
            .flatMapBuild { _ in
                if Bool.random() {
                    Fail(error: CustomError())
                } else {
                    PassthroughSubject<Int, Error>()
                }
            }
            .mapError { _ in CustomError() }
            .eraseToAnyPublisher()
    }
}
