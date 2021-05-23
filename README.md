# PublisherBuilder

`PublisherBuilder` provides easy way to build a complex `Publisher` powered by `@resultBuilder`.

## Example

Replace with `flatMapBuild` to simplify `flatMap`.

```swift
let _: AnyPublisher<[String], Error> = PassthroughSubject<Int, Never>()
    .flatMap { v -> AnyPublisher<[String], Error> in // return type annotation
        if Bool.random() {
            return PassthroughSubject<[String], Never>()
                .setFailureType(to: Error.self) // setting Failure type
                .eraseToAnyPublisher() // type erasing
        } else {
            return PassthroughSubject<[String], Error>()
                .eraseToAnyPublisher()
        }
    }
    .eraseToAnyPublisher()
```

↓

```swift
let _: AnyPublisher<[String], Error> = PassthroughSubject<Int, Never>()
    .flatMapBuild { v in
        if Bool.random() {
            PassthroughSubject<[String], Never>()
        } else {
            PassthroughSubject<[String], Error>()
        }
    }
    .eraseToAnyPublisher()
```

## Feature

### Branch combining

```swift
PublisherBuilder.build {
    if Bool.random() {
        PassthroughSubject<Int, Never>()
    } else {
        CurrentValueSubject<Int, Never>()
    }    
} // EitherPublisher<PassthroughSubject<Int, Never>, CurrentValueSubject<Int, Never>>
```

### Convert error type

```swift
.flatMapBuild { _ in
    if Bool.random() {
        PassthroughSubject<Int, Never>() // automaticaly add .setFailureType(to: Error.self)
    } else {
        PassthroughSubject<Int, Error>()
    }
} // some Publisher where Output == Int, Failure == Error
```

### Convert optional type

```swift
.flatMapBuild { _ in
    if Bool.random() {
        PassthroughSubject<Int?, Never>()
    } else {
        PassthroughSubject<Int, Never>() // automaticaly add .map { $0 }
    }
} // some Publisher where Output == Int?, Failure == Never
```

### strong type inference

```swift
let _: AnyPublisher<[String], CustomError> = PassthroughSubject<[Int], Never>()
    .flatMapBuild { v in
        if v.isEmpty {
            Just([]) // inferred Just<[String], CustomError>
        } else {
            Fail(error: CustomError())
        }
    }
    .eraseToAnyPublisher()
```
 
## Installation

SwiftPM

```
.package(url: "https://github.com/sidepelican/PublisherBuilder.git", from: "1.0.0")
```

## License

The MIT License. See the LICENSE file for more infomation.
