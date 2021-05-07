import Combine

extension Publisher {
    @_disfavoredOverload
    public func flatMapBuild<O, P>(
        to outputType: O.Type = O.self,
        @PublisherBuilder<O, Failure> _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Self>
    where O == P.Output, P: Publisher, P.Failure == Failure
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