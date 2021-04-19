import Combine
import XCTest
@testable import FlatMapBuilder

let neverSubject = PassthroughSubject<[Int], Never>()
let errorSubject = PassthroughSubject<[String], Error>()

final class FlatMapBuilderTests: XCTestCase {
    func testExample() {
        let _: AnyPublisher<[String], Never> = neverSubject
            .flatMapBuild { v in
                Just([])
            }
            .eraseToAnyPublisher()
    }

    func testExample2() {
        let _: AnyPublisher<[String], Error> = neverSubject
            .flatMapBuild { v in
                errorSubject
                    .catch { _ in
                        Empty()
                    }
            }
            .eraseToAnyPublisher()
    }

    func testExample3() {
        let _: AnyPublisher<[String], Error> = neverSubject
            .flatMapBuild { v in
                if v.isEmpty {
                    Just([])
                } else {
                    Just([])
                }
            }
            .eraseToAnyPublisher()

        let _: AnyPublisher<[String], Error> = neverSubject
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
    }
}
