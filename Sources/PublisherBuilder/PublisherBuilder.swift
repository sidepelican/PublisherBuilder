import Combine

@_functionBuilder
public struct PublisherBuilder<Output, Failure: Error> {
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

    public static func buildBlock<C: Publisher>(_ component: C) -> C {
        component
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

extension PublisherBuilder {
    public static func build<P: Publisher>(@PublisherBuilder<Output, Failure> builder: () -> P) -> P where P.Output == Output, P.Failure == Failure {
        builder()
    }
}
