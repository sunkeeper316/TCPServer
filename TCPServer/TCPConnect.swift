import Foundation
import Network

class TcpConnect {

    init(hostName: String, port: Int) {
        let host = NWEndpoint.Host(hostName)
        let port = NWEndpoint.Port("\(port)")!
        self.connection = NWConnection(host: host, port: port, using: .tcp)
    }

    let connection: NWConnection

    func start() {
        NSLog("will start")
        self.connection.stateUpdateHandler = self.didChange(state:)
        self.startReceive()
        self.connection.start(queue: .main)
    }

    func stop() {
        self.connection.cancel()
        NSLog("did stop")
    }

    private func didChange(state: NWConnection.State) {
        switch state {
        case .setup:
            break
        case .waiting(let error):
            NSLog("is waiting: %@", "\(error)")
        case .preparing:
            break
        case .ready:
            break
        case .failed(let error):
            NSLog("did fail, error: %@", "\(error)")
            self.stop()
        case .cancelled:
            NSLog("was cancelled")
            self.stop()
        @unknown default:
            break
        }
    }

    private func startReceive() {
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isDone, error in
            if let data = data, !data.isEmpty {
                NSLog("did receive, data: %@", data as NSData)
            }
            if let error = error {
                NSLog("did receive, error: %@", "\(error)")
                self.stop()
                return
            }
            if isDone {
                NSLog("did receive, EOF")
                self.stop()
                return
            }
            self.startReceive()
        }
    }

    func send(line: String) {
        let data = Data("\(line)\r\n".utf8)
        self.connection.send(content: data, completion: NWConnection.SendCompletion.contentProcessed { error in
            if let error = error {
                NSLog("did send, error: %@", "\(error)")
                self.stop()
            } else {
                NSLog("did send, data: %@", data as NSData)
            }
        })
    }

    static func run() -> Never {
        let m = TcpConnect(hostName: "127.0.0.1", port: 12345)
        m.start()

        let t = DispatchSource.makeTimerSource(queue: .main)
        var counter = 99
        t.setEventHandler {
            m.send(line: "\(counter) bottles of beer on the wall.")
            counter -= 1
            if counter == 0 {
                m.stop()
                exit(EXIT_SUCCESS)
            }
        }
        t.schedule(wallDeadline: .now() + 1.0, repeating: 1.0)
        t.activate()

        dispatchMain()
    }
}


