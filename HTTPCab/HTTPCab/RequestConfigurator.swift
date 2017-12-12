//
//  HTTPCabProvider.swift
//  HTTPCab
//
//  Created by Igor Voytovich on 12/5/17.
//  Copyright © 2017 Graviti Mobail. All rights reserved.
//

import Foundation

public class RequestConfigurator<T: ProviderConfiguration> {
    
    let networkManager: NetworkManager
    
    public init(networkManager: NetworkManager = NetworkManager.default) {
        self.networkManager = networkManager
    }
    
    @discardableResult
    public func request(_ configuration: T, completion: @escaping RequestStatusCompletion) -> URLTask? {
        let task = defaultTaskForConfiguration(configuration)
        do {
            let urlRequest = try task.urlRequest()
            return standardRequest(urlRequest: urlRequest, completion: completion)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func standardRequest(urlRequest: URLRequest, completion: @escaping RequestStatusCompletion) -> DataTask {
        return networkManager.request(urlRequest, completion: completion)
    }
}

public extension RequestConfigurator {
    private final func defaultTaskForConfiguration(_ configuration: T) -> Task<T> {
        return Task(url: URL(configuration: configuration).absoluteString
            , method: configuration.method, taskType: configuration.taskType, headers: configuration.headers)
    }
}

public extension URL {
    init<T: ProviderConfiguration>(configuration: T) {
        if configuration.path.isEmpty {
            self = configuration.baseURL
        } else {
            self = configuration.baseURL.appendingPathComponent(configuration.path)
        }
    }
}

extension URLRequest {
    mutating func encodeWithParameters(_ parameters: Parameters, andParametersEncoding encoding: ParametersEncoding) throws -> URLRequest {
        return try encoding.encodeUrlRequest(self, withParameters: parameters)
    }
    
    mutating func encodeWithEncodable(_ encodable: Encodable) throws -> URLRequest {
        do {
            let encodableObject = AnyEncodable(encodable)
            httpBody = try JSONEncoder().encode(encodableObject)
            return self
        } catch {
            throw HTTPCabError.mappingError(error: .encodableMapping)
        }
    }
}
