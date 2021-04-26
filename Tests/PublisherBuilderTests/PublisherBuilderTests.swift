import Combine
import XCTest
@testable import PublisherBuilder

let neverSubject = PassthroughSubject<[Int], Never>()
let errorSubject = PassthroughSubject<[String], Error>()
struct CustomError: Error {}
let customErrorSubject = PassthroughSubject<[Double], CustomError>()

final class PublisherBuilderTests: XCTestCase {
    func testExample() {
        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v -> AnyPublisher<[String], Never> in
                Just([])
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v in
                Just([""])
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild(to: [String].self) { v in
                Just([])
            }
            .eraseToAnyPublisher()
    }

    func testExample2() {
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

    func testExample3() {
        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild(to: [String].self) { v in
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
                    Just([""])
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
            .flatMapBuild(to: [String].self) { v in
                if v.isEmpty {
                    Just([])
                } else {
                    errorSubject
                }
            }
            .eraseToAnyPublisher()
    }

    func testMultipleExpressions() {
        let _: AnyPublisher<[String], Error> = neverSubject
            .flatMapBuild { v in
                let _ = 1
                let _ = Int("")
                let (_, _) = 1.remainderReportingOverflow(dividingBy: 1)
                errorSubject
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v -> AnyPublisher<[String], Never> in
                var a: () = ()
                Just([])
                let _ = a = a = a
            }
            .eraseToAnyPublisher()
    }

    func testUpcastError() -> AnyPublisher<[Double], Error> {
        PublisherBuilder.build {
            customErrorSubject
        }
    }

    func testUpcastError2() -> AnyPublisher<Void, Error> {
        PublisherBuilder.build {
            if Bool.random() {
                customErrorSubject.map { _ in }
            } else if Bool.random() {
                errorSubject.map { _ in }
            } else {
                neverSubject.map { _ in }
            }
        }
    }

    func testUpcastError3() -> AnyPublisher<Void, CustomError> {
        PublisherBuilder.build {
            if Bool.random() {
                customErrorSubject.map { _ in }
            } else {
                neverSubject.map { _ in }
            }
        }
    }

    func testAsAnyPublisher() -> AnyPublisher<[String], Error> {
        PublisherBuilder.build {
            errorSubject
        }
    }

    func testNotAsAnyPublisher() -> PassthroughSubject<[String], Error> {
        PublisherBuilder.build {
            errorSubject
        }
    }

    func testWithAnyPublisherReturnType() {
        let _: AnyPublisher<[String], Error> = build {
            Empty()
        }

        let _: () -> AnyPublisher<[String], Error> = build {
            Empty()
        }

        let _: (Int) -> AnyPublisher<[String], Error> = build { _ in
            Empty()
        }

        let _: (Int, Int) -> AnyPublisher<[String], Error> = build { _, _ in
            Empty()
        }
    }
}

private func build<P: Publisher>(@PublisherBuilder<P.Output, P.Failure> builder: () -> P) -> P {
    builder()
}

private func build<P: Publisher>(@PublisherBuilder<P.Output, P.Failure> builder: @escaping () -> P) -> () -> P {
    { builder() }
}

private func build<P: Publisher, C0>(@PublisherBuilder<P.Output, P.Failure> builder: @escaping (C0) -> P) -> (C0) -> P {
    { builder($0) }
}

private func build<P: Publisher, C0, C1>(@PublisherBuilder<P.Output, P.Failure> builder: @escaping (C0, C1) -> P) -> (C0, C1) -> P {
    { builder($0, $1) }
}
