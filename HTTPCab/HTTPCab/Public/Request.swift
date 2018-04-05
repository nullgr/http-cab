//
//  Request.swift
//  HTTPCab
//
//  Created by Aleksey Zgurskiy on 03.04.2018.
//  Copyright © 2018 Graviti Mobail, TOV. All rights reserved.
//

import Foundation

public enum Method: String {
  case get = "GET"
  case post = "POST"
  case head = "HEAD"
  case put = "PUT"
  case patch = "PATCH"
  case delete = "DELETE"
  case trace = "TRACE"
  case connect = "CONNECT"
  case options = "OPTIONS"
}

public protocol Request {
  var baseURL: String { get }
  var path: String { get }
  var method: Method { get }
  var parameters: [String: String]? { get }
  var bodyStream: InputStream? { get }
  var body: Any? { get }
  var encoder: BodyEncoder? { get }
  var headers: [String: String]? { get }
}

public extension Request {
  var bodyStream: InputStream? {
    return nil
  }
}
