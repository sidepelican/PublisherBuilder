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
struct PublisherBuilder {
    static func buildBlock<C: Publisher>(_ component: C) -> C {
        component
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
        @PublisherBuilder _ builder: @escaping (Self.Output) -> P
    ) -> Publishers.FlatMap<P, Self>
    where O == P.Output, P: Publisher, P.Failure == Failure
    {
        flatMap(builder)
    }
}


let _: AnyPublisher<[String], Never> = PassthroughSubject<Int, Never>()
    .flatMapBuild { v in
        if v == 0 {
            Just<[String]>([])
        } else {
            PassthroughSubject<[String], Error>()
                .catch { e in
                    Empty<[String], Never>()
                }
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
