import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Runloop scheduler") {
    let runloop = RunLoop.main
    
    let subscription = runloop.schedule(after: runloop.now, interval: .seconds(1), tolerance: .milliseconds(800)) {
        print("Timer fired")
    }
    
    runloop.schedule(after: .init(Date(timeIntervalSinceNow: 3.0))) {
        subscription.cancel()
    }
}

example(of: "Timer publisher") {
    let _ = Timer
        .publish(every: 1.0, on: .main, in: .common)
        .autoconnect()
        .scan(0) { counter, _ in counter + 1 }
        .sink { print("Counter is \($0)") }
        .store(in: &subscriptions)
}

example(of: "DispatchQueue timer") {
    let queue = DispatchQueue.main
    let source = PassthroughSubject<Int, Never>()
    var counter = 0
    var _ = queue.schedule(after: queue.now, interval: .seconds(1)) {
        source.send(counter)
        counter += 1
    }
        .store(in: &subscriptions)
    let _ = source
        .sink { print("Timer emitted \($0)") }
        .store(in: &subscriptions)
}
