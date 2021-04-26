import Combine

@_functionBuilder
public struct PublisherBuilder<Output, Failure: Error> {
    public static func buildBlock<C: Publisher>(_ component: C) -> C {
        component
    }

    public static func buildBlock<C: Publisher>(_ component: C) -> AnyPublisher<Output, Failure>
    where
        Output == C.Output, Failure == C.Failure
    {
        component.eraseToAnyPublisher()
    }

    @_disfavoredOverload
    public static func buildExpression<E>(_ expression: E) -> E {
        expression
    }

    public static func buildExpression<P: Publisher>(_ expression: P) -> P
    where
        P.Output == Output, P.Failure == Failure
    {
        expression
    }

    @_disfavoredOverload
    public static func buildExpression<P: Publisher>(_ expression: P) -> Publishers.MapError<P, Failure>
    where
        P.Output == Output, Failure == Error
    {
        expression.mapError { $0 as Error }
    }

    public static func buildEither<F: Publisher, S: Publisher>(first component: F) -> EitherPublisher<F, S>
    where
        F.Output == S.Output,
        F.Failure == S.Failure
    {
        .left(component)
    }

    public static func buildEither<F: Publisher, S: Publisher>(second component: S) -> EitherPublisher<F, S>
    where
        F.Output == S.Output,
        F.Failure == S.Failure
    {
        .right(component)
    }

    @_disfavoredOverload
    public static func buildEither<F: Publisher, S: Publisher>(first component: F) -> EitherPublisher<Publishers.SetFailureType<F, S.Failure>, S>
    where
        F.Output == S.Output,
        F.Failure == Never
    {
        .left(component.setFailureType(to: S.Failure.self))
    }

    @_disfavoredOverload
    public static func buildEither<F: Publisher, S: Publisher>(second component: S) -> EitherPublisher<F, Publishers.SetFailureType<S, F.Failure>>
    where
        F.Output == S.Output,
        S.Failure == Never
    {
        .right(component.setFailureType(to: F.Failure.self))
    }

    @_disfavoredOverload
    public static func buildEither<F: Publisher, S: Publisher>(first component: F) -> EitherPublisher<Publishers.MapError<F, Failure>, S>
    where
        F.Output == S.Output,
        Failure == Error
    {
        .left(component.mapError { $0 as Failure })
    }

    @_disfavoredOverload
    public static func buildEither<F: Publisher, S: Publisher>(second component: S) -> EitherPublisher<F, Publishers.MapError<S, Failure>>
    where
        F.Output == S.Output,
        Failure == Error
    {
        .right(component.mapError { $0 as Failure })
    }
}

public enum EitherPublisher<L: Publisher, R: Publisher>: Publisher
where
    L.Output == R.Output, L.Failure == R.Failure
{
    public typealias Output = L.Output
    public typealias Failure = L.Failure
    case left(L)
    case right(R)

    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        switch self {
        case .left(let value):
            value.receive(subscriber: subscriber)
        case .right(let value):
            value.receive(subscriber: subscriber)
        }
    }
}

extension Publisher {
    @_disfavoredOverload
    public func flatMapBuild<O, F, P>(
        to outputType: O.Type = O.self,
        @PublisherBuilder<O, F> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Self>
    where O == P.Output, F == P.Failure, P: Publisher, P.Failure == Failure
    {
        flatMap(builder)
    }

    @_disfavoredOverload
    public func flatMapBuild<O, P>(
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
    public func flatMapBuild<O, F, P>(
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

    public func flatMapBuild<O, P>(
        to outputType: O.Type = O.self,
        @PublisherBuilder<O, Never> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Self>
    where O == P.Output, P: Publisher, P.Failure == Never
    {
        flatMap(builder)
    }
}
