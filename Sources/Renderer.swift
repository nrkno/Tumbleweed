//
//  Renderer.swift
//  Tumbleweed
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

extension TimeInterval {
    var ms: String {
        return String(format: "%.1f", self * 1000)
    }
}

public protocol Renderer {
    func render(with stats: Tumbleweed)
}

public struct ConsoleRenderer: Renderer {
    public var printer: (String) -> Void = { NSLog($0) }

    public init() {

    }

    public func render(with stats: Tumbleweed) {
        printer("Task ID: \(stats.task.taskIdentifier) (redirects: \(stats.redirectCount))")
        for metric in stats.metrics {
            printer(renderHeader(with: metric))
            printer(renderMeta(with: metric))
            let totalDuration = metric.durations.filter({ $0.type == .total }).first
            for line in metric.durations.filter({ $0.type != .total }) {
                printer(renderDuration(line: line, total: totalDuration?.interval))
            }
        }
    }

    func renderHeader(with metric: Metric) -> String {
        let method = metric.transactionMetrics.request.httpMethod ?? "???"
        let url = metric.transactionMetrics.request.url?.absoluteString ?? "???"

        let responseLine: String
        if let response = metric.transactionMetrics.response as? HTTPURLResponse {
            let mime = response.mimeType ?? ""
            responseLine = "\(response.statusCode) \(mime)"
        } else {
            responseLine = "[response error]"
        }
        return "\(method) \(url) -> \(responseLine), through \(metric.transactionMetrics.resourceFetchType.name)"
    }

    func renderDuration(line: Metric.Duration, total: DateInterval?) -> String {
        let name = line.type.name.padding(toLength: 18, withPad: " ", startingAt: 0)
        let plot = total.flatMap({ visualize(interval: line.interval, total: $0) }) ?? ""
        return "\(name) \(plot) \(line.interval.duration.ms)"
    }

    func visualize(interval: DateInterval, total: DateInterval, within width: Int = 100) -> String {
        precondition(total.intersects(total), "supplied duration does not intersect with the total duration")
        let relativeStart = (interval.start.timeIntervalSince1970 - total.start.timeIntervalSince1970) / total.duration
        let relativeEnd = 1.0 - (total.end.timeIntervalSince1970 - interval.end.timeIntervalSince1970) / total.duration

        let factor = 1.0 / Double(width)
        let startIndex = Int((relativeStart / factor))
        let endIndex = Int((relativeEnd / factor))

        let line: [String] = (0..<width).map { position in
            if position >= startIndex && position <= endIndex {
                return "#"
            } else {
                return " "
            }
        }
        return "|\(line.joined())|"
    }

    private func renderMeta(with metric: Metric) -> String {
        let networkProtocolName = metric.transactionMetrics.networkProtocolName ?? "???"
        let meta = [
            "protocol: \(networkProtocolName)",
            "proxy: \(metric.transactionMetrics.isProxyConnection)",
            "reusedconn: \(metric.transactionMetrics.isReusedConnection)",
        ]
        return meta.joined(separator: " ")
    }
}
