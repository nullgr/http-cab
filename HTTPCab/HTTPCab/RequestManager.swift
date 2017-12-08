//
//  HTTPManager.swift
//  HTTPCab
//
//  Created by Igor Voytovich on 12/5/17.
//  Copyright © 2017 Graviti Mobail. All rights reserved.
//

import Foundation

open class RequestManager {
    
    open static let `default`: RequestManager = {
        return RequestManager(urlSessionConfiguration: URLSessionConfiguration.default)
    }()
    
    var session: URLSession
    let samaphoreTimeout: DispatchTime
    
    init(urlSessionConfiguration: URLSessionConfiguration = .default, semaphoreTimeout: DispatchTime = DispatchTime.distantFuture) {
        self.session = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: nil)
        self.samaphoreTimeout = semaphoreTimeout
    }
    
    @discardableResult
    open func request(_ url: URL, method: Method = .get,
                      parameters: Parameters? = nil,
                      headers: HTTPHeaders? = nil,
                      parametersEncoding: ParametersEncoding = URLEncoding.default,
                      completion: @escaping RequestStatusCompletion) -> URLSessionDataTask? {
        let originalRequest = URLRequest(url: url, method: method, headers: headers)
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        do {
            let encodedUrlRequest = try parametersEncoding.encodeUrlRequest(originalRequest, withParameters: parameters)
            let dataTask = session.dataTask(with: encodedUrlRequest) { data, urlResponse, error in
                dispatchSemaphore.signal()
                if let error = error {
                    completion(.failure(error: error))
                }
                
                guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
                    return
                }
                
                completion(.success(value: RequestResult(statusCode: httpUrlResponse.statusCode, data: data)))
            }
            
            dataTask.resume()
            
            _ = dispatchSemaphore.wait(timeout: samaphoreTimeout)
            return dataTask
        } catch {
            return nil
        }
    }
    
    @discardableResult
    open func request(_ urlRequest: URLRequest, completion: @escaping RequestStatusCompletion) -> URLSessionDataTask {
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        let dataTask = session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if let error = error {
                completion(.failure(error: error))
            }
            
            guard let httpUrlResponse = urlResponse as? HTTPURLResponse else { return }
            
            dispatchSemaphore.signal()
            completion(.success(value: RequestResult(statusCode: httpUrlResponse.statusCode, data: data)))
        }
        
        dataTask.resume()
        
        _ = dispatchSemaphore.wait(timeout: samaphoreTimeout)
        return dataTask
    }
}
