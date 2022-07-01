import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "KVO for OperationQueue") {
    let queue = OperationQueue()
    let _ = queue.publisher(for: \.operationCount)
        .sink {
            print("Outstanding opeartions in queue: \($0)")
        }
        .store(in: &subscriptions)
}

example(of: "One's own KVO object") {
    class TestObject: NSObject {
        @objc dynamic var integerProperty: Int = 0
        @objc dynamic var stringProperty: String = ""
        @objc dynamic var arrayProperty: [Float] = []
    }
    
    let obj = TestObject()
    
    let _ = obj.publisher(for: \.integerProperty)
        .sink {
            print("integerProperty changes to \($0)")
        }
        .store(in: &subscriptions)
    
    let _ = obj.publisher(for: \.stringProperty)
        .sink {
            print("stringProperty changes to \($0)")
        }
        .store(in: &subscriptions)
    
    let _ = obj.publisher(for: \.arrayProperty)
        .sink {
            print("arrayProperty changes to \($0)")
        }
        .store(in: &subscriptions)
    
    obj.integerProperty = 100
    obj.integerProperty = 200
    
    obj.arrayProperty = [1.0]
    obj.stringProperty = "Hello"
    
    obj.arrayProperty = [1.0, 2.0]
    obj.stringProperty = "World"
}

example(of: "ObservableObject") {
    class MonitorObject: ObservableObject {
        @Published var somePropery = false
        @Published var someOtherProperty = ""
    }
    
    let object = MonitorObject()
    let _ = object.objectWillChange
        .sink {
            print("object will change")
        }
        .store(in: &subscriptions)
    
    object.somePropery = true
    object.someOtherProperty = "Hello World"
}
