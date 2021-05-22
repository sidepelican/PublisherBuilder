import Combine

enum EitherPublisher<L: Publisher, R: Publisher>: Publisher
where
    L.Output == R.Output, L.Failure == R.Failure
{
    typealias Output = L.Output
    typealias Failure = L.Failure
    case left(L)
    case right(R)

    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        switch self {
        case .left(let value):
            value.receive(subscriber: subscriber)
        case .right(let value):
            value.receive(subscriber: subscriber)
        }
    }
}

@resultBuilder
struct PublisherBuilder<Output, Failure: Error> {
    static func buildBlock<C: Publisher>(_ component: C) -> C {
        component
    }

    static func buildExpression<P: Publisher>(_ expression: P) -> P
    where
        P.Output == Output, P.Failure == Failure
    {
        expression
    }

    @_disfavoredOverload
    static func buildExpression<C: Publisher>(_ component: C) -> Publishers.MapError<C, Failure>
    where
        C.Output == Output, Failure == Error
    {
        component.mapError { $0 as Error }
    }

    @_disfavoredOverload
    static func buildExpression<P: Publisher>(_ expression: P) -> Publishers.SetFailureType<P, Failure>
    where
        P.Output == Output, P.Failure == Never
    {
        expression.setFailureType(to: Failure.self)
    }

    @_disfavoredOverload
    static func buildExpression<P: Publisher>(_ expression: P) -> Publishers.SetFailureType<P, Failure>
    where
        P.Output == Output, P.Failure == Never, Failure == Error
    {
        expression.setFailureType(to: Failure.self)
    }

    static func buildEither<F: Publisher, S: Publisher>(first component: F) -> EitherPublisher<F, S>
    where
        F.Output == S.Output,
        F.Failure == S.Failure
    {
        .left(component)
    }

    static func buildEither<F: Publisher, S: Publisher>(second component: S) -> EitherPublisher<F, S>
    where
        F.Output == S.Output,
        F.Failure == S.Failure
    {
        .right(component)
    }
}

extension Publisher {
    @_disfavoredOverload
    func flatMapBuild<O, P>(
        to outputType: O.Type = O.self,
        @PublisherBuilder<O, Failure> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Self>
    where O == P.Output, P: Publisher, P.Failure == Failure
    {
        flatMap(builder)
    }

    @_disfavoredOverload
    func flatMapBuild<O, P>(
        to outputType: O.Type = O.self,
        @PublisherBuilder<O, Never> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<Publishers.SetFailureType<P, Self.Failure>, Self>
    where O == P.Output, P: Publisher, P.Failure == Never
    {
        if #available(macOS 11.0, iOS 14.0, *) {
            return flatMap(builder)
        } else {
            return flatMap { builder($0).setFailureType(to: Failure.self) }
        }
    }
}

extension Publisher where Failure == Never {
    @_disfavoredOverload
    func flatMapBuild<O, F, P>(
        to outputType: O.Type = O.self,
        @PublisherBuilder<O, F> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Publishers.SetFailureType<Self, P.Failure>>
    where O == P.Output, F == P.Failure, P: Publisher
    {
        if #available(macOS 11.0, iOS 14.0, *) {
            return flatMap(builder)
        } else {
            return setFailureType(to: P.Failure.self).flatMap(builder)
        }
    }

    func flatMapBuild<O, P>(
        to outputType: O.Type = O.self,
        @PublisherBuilder<O, Never> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Self>
    where O == P.Output, P: Publisher, P.Failure == Never
    {
        flatMap(builder)
    }
}

struct MyError: Error {} 

let _: AnyPublisher<[String], MyError> = PassthroughSubject<Int, Never>() // Failure == Never
    .flatMapBuild { v in
        if Bool.random() {
            PassthroughSubject<[String], Never>() // Failure == Never
        } else {
            PassthroughSubject<[String], MyError>() // Failure == MyError
        }
    }
    .eraseToAnyPublisher()

let _: AnyPublisher<[String], Error> = PassthroughSubject<Int, Never>() // Failure == Never
    .flatMapBuild { v in
        if Bool.random() {
            PassthroughSubject<[String], Never>() // Failure == Never
        } else if Bool.random() {
            PassthroughSubject<[String], MyError>() // Failure == MyError
        } else {
            PassthroughSubject<[String], Error>() // Failure == Error
        }
    }
    .eraseToAnyPublisher()

// シュッとかけるようにしたいコード
let _: AnyPublisher<[String], Never> = PassthroughSubject<Int, Never>()
    .flatMap { v -> AnyPublisher<[String], Never> in
        if v == 0 {
            return Just([])
                .eraseToAnyPublisher()
        } else {
            return PassthroughSubject<[String], Error>()
                .catch { e in
                    Empty()
                }
                .eraseToAnyPublisher()
        }
    }
    .eraseToAnyPublisher()
