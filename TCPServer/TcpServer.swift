import Network
import Foundation
import UIKit

public class TcpServer {
    
    public static var shared:TcpServer?
    public static func startServer(at port: UInt16) {
        shared = TcpServer(port: port)
        try! shared!.start()
    }
    public static func cencelServer() {
        if (shared != nil){
            shared!.listener.cancel()
            shared = nil
        }
        
    }
//    private let port: NWEndpoint.Port
    let listener: NWListener
    
    public init(port: UInt16) {
//        let port = NWEndpoint.Port(rawValue: port)!
//        let host = NWEndpoint.Host("127.0.0.1")
        let TLS_opts = NWProtocolTLS.Options()
           let TCP_opts = NWProtocolTCP.Options()
               TCP_opts.disableECN         = true    // Explicit Congestion Notification
               TCP_opts.enableKeepalive    = false   // Send Keep-Alive packets
               TCP_opts.connectionTimeout  = 60      // Connection handshake timeout (seconds)
               TCP_opts.connectionDropTime = 5       // Seconds TCP will do packet retransmission
//        let sec_opts = TLS_opts.securityProtocolOptions
        // I’m completely stuck in the sparse documentation at this point!
        // For testing purposes, I have a self-signed certificate in the System keychain with
        // the identifier: “Server.local”
        // How do I enable TLS using this (or a real) certificate?
           let Parameters = NWParameters(tls: TLS_opts, tcp: TCP_opts)
               Parameters.allowLocalEndpointReuse = true
//        let parameters = NWParameters.tcp.copy()
//        parameters.requiredLocalEndpoint = .hostPort(host: host, port: self.port)
//        self.listener = try! NWListener(using: Parameters, on: NWEndpoint.Port(rawValue: port)!)
        self.listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!)
    }
    public  func start() throws {
        self.listener.stateUpdateHandler = self.stateDidChange(to:)
        self.listener.newConnectionHandler = self.didAccept(for:)
        self.listener.start(queue: .global())
    
//        self.listener.newConnectionGroupHandler = { connection in
//            connection.setReceiveHandler { message, content, isComplete in
//            }
//        }
    }
    public func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .setup:
            print("setup")
            break
        case .cancelled:
            print("cancelled")
        case .waiting(_):
            print("waiting")
        case .ready:
            print("ready")
        case .failed(let error):
            print(error.localizedDescription)
            print("failed")
            break
        @unknown default:
            break
        }
    }
    
    private func didAccept(for connection: NWConnection) {
        print(connection.endpoint)
//        connection.parameters = NWParameters.tcp
        connection.start(queue: .global())
        connection.stateUpdateHandler = { newState in
            switch newState {
                case .ready:
                    print("State: Ready")
//                    connection.receive()
                case .setup:
                    print("State: Setup")
                case .cancelled:
                    print("State: Cancelled")
                case .preparing:
                    print("State: Preparing")
                default:
                    print("ERROR! State not defined!\n")
            }
            
        }
        receiveHandler()
        func receiveHandler(){
            connection.receive(minimumIncompleteLength: 1, maximumLength: 1024*8, completion: { data, contentContext, isComplete, error in
                if let data = data {
                    print(String(data: data, encoding: .utf8))
                    receiveHandler()
                }
            })
        }
        
    }
    
    
}
