//
//  Tumbleweed.swift
//  NRK
//
//  Created by Johan Sørensen on 06/04/2017.
//  Copyright © 2017 NRK. All rights reserved.
//

import Foundation

/// An object that is capable of collection metrics based on a given set of URLSessionTaskMetrics
@available(iOS 10.0, *)
public struct SessionMetrics {
    public let task: URLSessionTask
    public let metrics: [Metric]
    public let redirectCount: Int
    public let taskInterval: DateInterval

    public init(source sessionTaskMetrics: URLSessionTaskMetrics, task: URLSessionTask) {
        self.task = task
        self.redirectCount = sessionTaskMetrics.redirectCount
        self.taskInterval = sessionTaskMetrics.taskInterval
        self.metrics = sessionTaskMetrics.transactionMetrics.map(Metric.init(transactionMetrics:))
    }

    public func render(with renderer: Renderer) {
        renderer.render(with: self)
    }
}

/// Convenience object that can be used as the delegate for a URLSession
/// eg let session = URLSession(configuration: .default, delegate: SessionMetricsLogger(), delegateQueue: nil)
@available(iOS 10.0, *)
public final class SessionMetricsLogger: NSObject, URLSessionTaskDelegate {
    let renderer = ConsoleRenderer()

    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        let gatherer = SessionMetrics(source: metrics, task: task)
        renderer.render(with: gatherer)
    }
}
