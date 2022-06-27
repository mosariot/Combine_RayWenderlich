import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

struct MyType: Codable { }

example(of: "Networking") {
    guard let url = URL(string: "https://mysite.com/mydata.json") else { return }
    
    let _ = URLSession.shared
        .dataTaskPublisher(for: url)
        .sink { completion in
            if case .failure(let err) = completion {
                print("Retrieving data faled with error \(err)")
            }
        } receiveValue: { data, response in
            print("Retrieved data of size \(data.count), response = \(response)")
        }
        .store(in: &subscriptions)
}

example(of: "Networking with decoding") {
    guard let url = URL(string: "https://mysite.com/mydata.json") else { return }
    
    let _ = URLSession.shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: MyType.self, decoder: JSONDecoder())
        .sink { completion in
            if case .failure(let err) = completion {
                print("Retrieving data faled with error \(err)")
            }
        } receiveValue: { object in
            print("Retrieved object \(object)")
        }
        .store(in: &subscriptions)
}

example(of: "Connecting multiple subscribers to the networking publiher") {
    guard let url = URL(string: "https://mysite.com/mydata.json") else { return }
    
    let publisher = URLSession.shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .multicast {
            PassthroughSubject<Data, URLError>()
        }
    
    let _ = publisher
        .sink { completion in
            if case .failure(let err) = completion {
                print("Sink1 Retrieving data faled with error \(err)")
            }
        } receiveValue: { object in
            print("Sink1 Retrieved object \(object)")
        }
        .store(in: &subscriptions)
    
    let _ = publisher
        .sink { completion in
            if case .failure(let err) = completion {
                print("Sink2 Retrieving data faled with error \(err)")
            }
        } receiveValue: { object in
            print("Sink2 Retrieved object \(object)")
        }
        .store(in: &subscriptions)
    
    let _ = publisher
        .connect()
        .store(in: &subscriptions)
}
