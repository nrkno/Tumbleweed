# Tumbleweed 

Logs detailed metrics about URLSession tasks to the console, such as DNS lookup durations, request and response times and more. Tumbleweed works by parsing the metrics collected by the `URLSessionTaskMetrics` introduced in iOS 10.0.

## Example output

```
Task ID: 1 lifetime: 594.9ms redirects: 0
GET https://github.com/ -> 200 text/html, through network-load
protocol: http/1.1 proxy: false reusedconn: false
domain lookup     |#                                                                               |   3.0ms
connect           |###############################################                                 | 330.0ms
secure connection |               ################################                                 | 223.0ms
request           |                                               #                                |   0.2ms
server            |                                               ###################              | 130.9ms
response          |                                                                 ###############| 105.8ms
                                                                                             total   575.0ms
```

A few notes on the data:
* Task lifetime is the time of the URLSessionTask creation to the response is delivered.
* The "through" key on the second line will tell you whether the response was fetched from cache, delivered by server push or by network load.
* "server" is how long the server spent processing the request

_Note_ that not all responses will deliver complete metrics, such as local cache fetches and other non-network loaded responses.

## Usage

In your `URLSessionDelegate`:

```swift
func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    let stats = SessionMetrics(source: metrics, task: task)
    let renderer = ConsoleRenderer()
    renderer.render(with: stats)
}
```

As a convenience Tumbleweed provides the `SessionMetricsLogger` which can be set as the `URLSessionDelegate` on `URLSession`, if you're not using any of the other delegates.

```Swift
let sessionDelegate: URLSessionDelegate?
if #available(iOS 10.0, *) {
sessionDelegate = SessionMetricsLogger()
} else {
    sessionDelegate = nil
}
let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
```

## Installation

Tumbleweed is available as a CocoaPod (`pod 'Tumbleweed'`) and the Swift Package Manager. Framework installation is also available by dragging the Tumbleweed.xcodeproj into your project or via Carthage.

Tumbleweed has no dependencies outside of Foundation.

## License

See the LICENSE file
