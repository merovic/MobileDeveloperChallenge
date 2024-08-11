//
//  APIClient.swift
//  CombineNetworking
//
//  Created by Amir Ahmed on 11/12/2023.
//

import Foundation
import Combine
import Alamofire

class APIClient {
    private static var cancellables: Set<AnyCancellable> = []
    
    @discardableResult
    static func performDecodableRequest<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, AFError> where T: Decodable {
        return Future<T, AFError> { promise in
            let urlKey = route.urlRequest?.url?.absoluteString ?? ""
            
            // Check if data is available in cache
            if let cachedData = DataCacheManager.shared.fetchData(forKey: urlKey) {
                do {
                    let decodedObject = try decoder.decode(T.self, from: cachedData)
                    promise(.success(decodedObject))
                    return
                } catch {
                    promise(.failure(AFError.responseSerializationFailed(reason: .decodingFailed(error: error))))
                    return
                }
            }
            
            // If no cached data, proceed with network request
            AF.request(route)
                .publishDecodable(type: T.self, decoder: decoder, emptyResponseCodes: [200, 204, 205])
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error.asAFError(orFailWith: "Error")))
                    }
                } receiveValue: { response in
                    if let value = response.value {
                        if let data = response.data {
                            DataCacheManager.shared.cacheData(data, forKey: urlKey)
                        }
                        promise(.success(value))
                    } else if let error = response.error {
                        promise(.failure(error))
                    } else {
                        let unknownError = AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                        promise(.failure(unknownError))
                    }
                }
                .store(in: &cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    @discardableResult
    static func performStringRequest(route: APIRouter) -> AnyPublisher<String, AFError> {
        return Future<String, AFError> { promise in
            let urlKey = route.urlRequest?.url?.absoluteString ?? ""
            
            // Check if data is available in cache
            if let cachedData = DataCacheManager.shared.fetchData(forKey: urlKey),
               let cachedString = String(data: cachedData, encoding: .utf8) {
                promise(.success(cachedString))
                return
            }
            
            // If no cached data, proceed with network request
            AF.request(route)
                .validate(statusCode: 200..<300)
                .publishString(encoding: .utf8)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error.asAFError(orFailWith: "Error")))
                    }
                } receiveValue: { response in
                    if let responseString = response.value {
                        if let data = responseString.data(using: .utf8) {
                            DataCacheManager.shared.cacheData(data, forKey: urlKey)
                        }
                        promise(.success(responseString))
                    } else {
                        let unknownError = AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                        promise(.failure(unknownError))
                    }
                }
                .store(in: &cancellables)
            
        }
        .eraseToAnyPublisher()
    }
}
