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
    static func buildFinalResult<C: Publisher>(_ component: C) -> C {
        component
    }

    @_disfavoredOverload
    static func buildFinalResult<C: Publisher>(_ component: C) -> AnyPublisher<Output, Failure>
    where
        Output == C.Output, Failure == C.Failure
    {
        component.eraseToAnyPublisher()
    }

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
    func flatMapBuild<O, P>(
        @PublisherBuilder<O, Failure> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Self>
    where O == P.Output, P: Publisher, P.Failure == Failure
    {
        flatMap(builder)
    }

    func flatMapBuild<O, P>(
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
    func flatMapBuild<O, F, P>(
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
        @PublisherBuilder<O, Never> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Self>
    where O == P.Output, P: Publisher, P.Failure == Never
    {
        flatMap(builder)
    }
}

let _: AnyPublisher<Int, Never> = PassthroughSubject<Int, Never>()
    .flatMapBuild { v -> AnyPublisher<[String], Never> in
        if Bool.random() {
            Just([])
        } else {
            Empty()
        }
    }
    .map(\.count)
    .eraseToAnyPublisher()

// シュッとかけるようにしたいコード
let _: AnyPublisher<Int, Never> = PassthroughSubject<Int, Never>()
    .flatMap { v -> AnyPublisher<[String], Never> in
        if Bool.random() {
            return Just([])
                .eraseToAnyPublisher()
        } else {
            return Empty()
                .eraseToAnyPublisher()
        }
    }
    .map(\.count)
    .eraseToAnyPublisher()
