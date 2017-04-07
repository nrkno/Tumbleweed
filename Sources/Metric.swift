//
//  Metric.swift
//  Tumbleweed
//
//  Created by Johan Sørensen on 06/04/2017.
//  Copyright © 2017 NRK. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
public protocol Measurable {
    var request: URLRequest { get }
    var response: URLResponse? { get }

    var networkProtocolName: String? { get }
    var isProxyConnection: Bool { get }
    var isReusedConnection: Bool { get }
    var resourceFetchType: URLSessionTaskMetrics.ResourceFetchType { get }

    var domainLookupStartDate: Date? { get }
    var domainLookupEndDate: Date? { get }

    var connectStartDate: Date? { get }
    var connectEndDate: Date? { get }
    var secureConnectionStartDate: Date? { get }
    var secureConnectionEndDate: Date? { get }

    var requestStartDate: Date? { get }
    var requestEndDate: Date? { get }
    var responseStartDate: Date? { get }
    var responseEndDate: Date? { get }
}

@available(iOS 10.0, *)
extension URLSessionTaskTransactionMetrics: Measurable {}

@available(iOS 10.0, *)
extension URLSessionTaskMetrics.ResourceFetchType {
    var name: String {
        switch self {
        case .unknown:
            return "unknown"
        case .networkLoad:
            return "network-load"
        case .serverPush:
            return "server-push"
        case .localCache:
            return "local-cache"
        }
    }
}

@available(iOS 10.0, *)
public struct Metric {
    public let transactionMetrics: Measurable
    public let durations: [Duration]

    public init(transactionMetrics metrics: Measurable) {
        self.transactionMetrics = metrics

        func check(type: DurationType, _ start: Date?, _ end: Date?) -> Duration? {
            guard let start = start, let end = end else { return nil }
            return Duration(type: type, interval: DateInterval(start: start, end: end))
        }

        var durations: [Duration] = []
        // domain, {secure}connect is nil f a persistent connection was used or it was retrieved from local cache
        if let duration = check(type: .domainLookup, metrics.domainLookupStartDate, metrics.domainLookupEndDate) {
            durations.append(duration)
        }
        if let duration = check(type: .connect, metrics.connectStartDate, metrics.connectEndDate) {
            durations.append(duration)
        }
        if let duration = check(type: .secureConnection, metrics.secureConnectionStartDate, metrics.secureConnectionEndDate) {
            durations.append(duration)
        }
        if let duration = check(type: .request, metrics.requestStartDate, metrics.requestEndDate) {
            durations.append(duration)
        }
        if let duration = check(type: .response, metrics.responseStartDate, metrics.responseEndDate) {
            durations.append(duration)
        }
        if let duration = check(type: .total, metrics.domainLookupStartDate, metrics.responseEndDate) {
            durations.append(duration)
        }

        self.durations = durations
    }

    internal init(transactionMetrics metrics: Measurable, durations: [Duration]) {
        self.transactionMetrics = metrics
        self.durations = durations
    }

    public enum DurationType {
        case domainLookup
        case connect
        case secureConnection
        case request
        case response
        case total

        public var name: String {
            switch self {
            case .domainLookup:
                return "domain lookup"
            case .connect:
                return "connect"
            case .secureConnection:
                return "secure connection"
            case .request:
                return "request"
            case .response:
                return "response"
            case .total:
                return "total"
            }
        }
    }

    public struct Duration {
        public let type: DurationType
        public let interval: DateInterval
    }
}
