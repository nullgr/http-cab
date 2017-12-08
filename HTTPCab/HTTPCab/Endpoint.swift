//
//  Endpoint.swift
//  HTTPCab
//
//  Created by Igor Voytovich on 12/7/17.
//  Copyright © 2017 Graviti Mobail. All rights reserved.
//

import Foundation

open class Endpoint<T> {
    open let url: String
    open let method: Method
    open let taskType: TaskType
    open let headers: HTTPHeaders?
    
    public init(url: String, method: Method, taskType: TaskType, headers: HTTPHeaders?) {
        self.url = url
        self.method = method
        self.taskType = taskType
        self.headers = headers
    }
}

extension Endpoint {
    public func urlRequest() throws -> URLRequest {
        guard let requestUrl = URL(string: url) else {
            throw HTTPCabError.mappingError(error: .requestMapping(url))
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        switch taskType {
        case .plainRequest:
            return request
        case .requestWithData(let data):
            request.httpBody = data
            return request
        case .requestWithEncodableType(let encodable):
            return try request.encodeWithEncodable(encodable)
        case .requestWithParameters(params: let params, encoding: let encoding):
            return try request.encodeWithParameters(params, andParametersEncoding: encoding)
        }
    }
}
