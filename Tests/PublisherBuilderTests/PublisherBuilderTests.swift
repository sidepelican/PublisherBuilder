import Combine
import XCTest
@testable import PublisherBuilder

private let neverSubject = PassthroughSubject<[Int], Never>()
private let errorSubject = PassthroughSubject<[String], Error>()
private struct CustomError: Error {}
private let customErrorSubject = PassthroughSubject<[Double], CustomError>()

final class PublisherBuilderTests: XCTestCase {
    func testMultipleExpressions() {
        _ = PublisherBuilder.build {
            let _ = 1
            let _ = Int("")
            let (_, _) = 1.remainderReportingOverflow(dividingBy: 1)
            errorSubject
        }

        let _: Just<[String]> = PublisherBuilder.build {
            var a: () = ()
            Just([])
            let _ = a = a = a
        }
    }

    func testUpcastError() {
        let _: AnyPublisher<[Double], Error> = PublisherBuilder.build {
            customErrorSubject
        }
    }

    func testUpcastError2() {
        let _: AnyPublisher<Void, Error> = PublisherBuilder.build {
            if Bool.random() {
                customErrorSubject.map { _ in }
            } else if Bool.random() {
                errorSubject.map { _ in }
            } else {
                neverSubject.map { _ in }
            }
        }
    }

    func testUpcastError3() {
        let _: AnyPublisher<Void, CustomError> = PublisherBuilder.build {
            if Bool.random() {
                customErrorSubject.map { _ in }
            } else {
                neverSubject.map { _ in }
            }
        }
    }

    func testNotAsAnyPublisher() {
        let _: PassthroughSubject<[String], Error> = PublisherBuilder.build {
            errorSubject
        }
    }

    func testNotTypeErased() {
        let some = PublisherBuilder.build {
            errorSubject
        }
        XCTAssertEqual("\(type(of: some).self)", "\(type(of: errorSubject))")
    }

    func testNestedBuilder() {
        let _: AnyPublisher<Void, CustomError> = PublisherBuilder.build {
            PublisherBuilder.build {
                Empty()
            }
        }
    }

    func testWithHandlerType() {
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
