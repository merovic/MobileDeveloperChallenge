//
//  CommonResponse.swift
//  Abshare
//
//  Created by Apple on 23/10/2021.
//

import Foundation

// MARK: - BaseResponse
public struct BaseResponse<T: Codable>: Codable, Equatable where T: Equatable {
    public var status: String
    public var code: Int
    public var error: String?
    public var data: T?
    
    public init(status: String, code: Int, error: String? = nil, data: T? = nil) {
        self.status = status
        self.code = code
        self.error = error
        self.data = data
    }
    
    public static func == (lhs: BaseResponse<T>, rhs: BaseResponse<T>) -> Bool {
        return lhs.status == rhs.status && lhs.code == rhs.code && lhs.error == rhs.error && lhs.data == rhs.data
    }
    
    public enum CodingKeys: String, CodingKey {
        case status = "status"
        case code = "code"
        case error = "error"
        case data = "data"
    }
}
