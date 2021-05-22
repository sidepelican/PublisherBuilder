import Combine

@resultBuilder
public struct PublisherBuilder<Output, Failure: Error> {
    public static func buildFinalResult<C: Publisher>(_ component: C) -> C {
        component
    }

    @_disfavoredOverload
    public static func buildFinalResult<C: Publisher>(_ component: C) -> AnyPublisher<Output, Failure>
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

    public static func buildExpression<P: Publisher>(_ expression: P) -> Publishers.Map<P, Optional<P.Output>>
    where
        Optional<P.Output> == Output, P.Failure == Failure
    {
        expression.map { $0 }
    }

    @_disfavoredOverload
    public static func buildExpression<E: Publisher>(_ expression: E) -> Publishers.MapError<E, Failure>
    where
        E.Output == Output, Failure == Error
    {
        expression.mapError { $0 as Error }
    }

    @_disfavoredOverload
    public static func buildExpression<P: Publisher>(_ expression: P) -> Publishers.SetFailureType<P, Failure>
    where
        P.Output == Output, P.Failure == Never
    {
        expression.setFailureType(to: Failure.self)
    }

    @_disfavoredOverload
    public static func buildExpression<P: Publisher>(_ expression: P) -> Publishers.SetFailureType<P, Failure>
    where
        P.Output == Output, P.Failure == Never, Failure == Error
    {
        expression.setFailureType(to: Failure.self)
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
}

extension PublisherBuilder {
    public static func build<P: Publisher>(@PublisherBuilder<Output, Failure> builder: () -> P) -> P where P.Output == Output, P.Failure == Failure {
        builder()
    }
}
