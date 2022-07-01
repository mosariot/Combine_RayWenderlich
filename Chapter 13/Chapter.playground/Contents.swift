import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Share Network request") {
    let shared = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .print("shared")
        .share()

    print("subscribing first")

    let _ = shared
        .sink { _ in } receiveValue: { print("subscription1 received: '\($0)'") }
        .store(in: &subscriptions)

    let _ = shared
        .sink { _ in } receiveValue: { print("subscription2 received: '\($0)'") }
        .store(in: &subscriptions)
}

example(of: "Multicast Network request with delay for second subscriber") {
    let subject = PassthroughSubject<Data, URLError>()
    
    let multicasted = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .print("multicast")
        .multicast(subject: subject)
    
    let _ = multicasted
        .sink { _ in } receiveValue: { print("subscription1 received: '\($0)'") }
        .store(in: &subscriptions)
    
    var subscription2: AnyCancellable? = nil
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        print("subscribing second")
        subscription2 = multicasted
            .sink { _ in } receiveValue: { print("subscription2 received: '\($0)'") }
        let _ = multicasted.connect().store(in: &subscriptions)
    }
}

example(of: "Future") {
    func performSomeWork() throws -> Int {
        print("Performing some work and returning a result")
        return 5
    }
    
    let future = Future<Int, Error> { fulfill in
        do {
            let result = try performSomeWork()
            fulfill(.success(result))
        } catch {
            fulfill(.failure(error))
        }
    }
    
    print("Subscribing to future...")
    
    let _ = future
        .sink(receiveCompletion: { _ in print("subscription1 completed") }, receiveValue: { print("subscription1 received: '\($0)'") })
        .store(in: &subscriptions)
    
    let _ = future
        .sink(receiveCompletion: { _ in print("subscription2 completed") }, receiveValue: { print("subscription2 received: '\($0)'") })
        .store(in: &subscriptions)
}
