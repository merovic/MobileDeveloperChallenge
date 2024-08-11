//
//  APIRouter.swift
//  CombineNetworking
//
//  Created by Amir Ahmed on 11/12/2023.
//

import Foundation
import Alamofire
import MessagePack

enum APIRouter: URLRequestConvertible {
    
    // MARK: - AuthModule
    case login(request: LoginAPIRequest)
    
    
    // MARK: - RequestParameterMethod
    private var requestParameter: RequestParameterMethod? {
        switch self {
        case .login:
            return .formParam
        }
    }
    
    // MARK: - contentType
    private var contentType: String {
        switch self {
        case .login:
            return "application/json"
        }
    }
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }
    
    // MARK: - EndPoint
    private var endpoint: String {
        switch self {
        case .login:
            return RemoteServers.ProductionServer.baseURL
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .login:
            return "/auth/login"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .login(request: let request):
            return request.dictionary
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        
        let url = try endpoint.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTPMethod
        urlRequest.httpMethod = method.rawValue
        
        // Header
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        urlRequest.setValue("en", forHTTPHeaderField: HTTPHeaderField.language.rawValue)
        urlRequest.setValue("Bearer \("authToken")", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
        
        // Parameters
        switch requestParameter {
        case .queryParam:
            if let parameters = parameters {
                urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)} else{
                urlRequest = try URLEncoding.queryString.encode(urlRequest, with: nil)
            }
        case .pathParam:
            break
        case .formParam:
            if let parameters = parameters {
                do {urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])} catch {
                    throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))}
            }
        case .none:
            break
        }
       
        return urlRequest
    }
}

public extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap {
            $0 as? [String: Any]
        }
    }
}
