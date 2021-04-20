import Combine
import XCTest
@testable import FlatMapBuilder

let neverSubject = PassthroughSubject<[Int], Never>()
let errorSubject = PassthroughSubject<[String], Error>()

final class FlatMapBuilderTests: XCTestCase {
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
}
