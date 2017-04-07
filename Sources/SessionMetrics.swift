//
//  Tumbleweed.swift
//  NRK
//
//  Created by Johan Sørensen on 06/04/2017.
//  Copyright © 2017 NRK. All rights reserved.
//

import Foundation

//header:   Task ID: 1 GET https://nrk.no/foo/bar (1st redirect) 200 OK
//meta:     protocol: HTTP/1.1 proxy: false, reusedconn: true, fetchtype: network-load
//duration  fetch start       |#                                               |  2.3ms
//duration  domain lookup     | ###                                            |  6.4ms
//duration  (secure) connect  |    ####                                        |  7.0ms
//duration  request           |        ###################                     | 24.4ms
//duration  response          |                           #####################| 56.8ms
//summary   [task lifetime: 1.6s]                                         total  96.9ms


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
