import Network
import Foundation
import UIKit

public class TcpServer {
    
    public static var shared:TcpServer?
    
//    public var connectHandler:((Bool) -> Void)?
//    public var resultHandler:((AnalysisObject) -> Void)?
    public var receiveHandler:((String) -> Void)?
    
    public static func startServer(at port: UInt16) {
        shared = TcpServer(port: port)
        try! shared!.start()
    }
    public static func startServer(ip:String, port: UInt16) {
        shared = TcpServer(ip:ip,port: port)
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
        self.listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!)
    }
    public init(ip: String ,port: UInt16) {
        let port = NWEndpoint.Port(rawValue: port)!
        let host = NWEndpoint.Host(ip)
//        let TLS_opts = NWProtocolTLS.Options()
//           let TCP_opts = NWProtocolTCP.Options()
//               TCP_opts.disableECN         = true    // Explicit Congestion Notification
//               TCP_opts.enableKeepalive    = false   // Send Keep-Alive packets
//               TCP_opts.connectionTimeout  = 60      // Connection handshake timeout (seconds)
//               TCP_opts.connectionDropTime = 5       // Seconds TCP will do packet retransmission
//        let sec_opts = TLS_opts.securityProtocolOptions
        // I’m completely stuck in the sparse documentation at this point!
        // For testing purposes, I have a self-signed certificate in the System keychain with
        // the identifier: “Server.local”
        // How do I enable TLS using this (or a real) certificate?
//           let Parameters = NWParameters(tls: TLS_opts, tcp: TCP_opts)
//               Parameters.allowLocalEndpointReuse = true
        let parameters = NWParameters.tcp.copy()
        parameters.requiredLocalEndpoint = .hostPort(host: host, port: port)
        self.listener = try! NWListener(using: parameters)
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
        receiveData()
        func receiveData(){
            connection.receive(minimumIncompleteLength: 1, maximumLength: 1024*8, completion: { data, contentContext, isComplete, error in
                if let data = data {
                    if let dataString = String(data: data, encoding: .utf8) {
                        print(dataString)
                        self.receiveHandler?(dataString)
                        AnalysisDP4800.analysisResult(dataBuffer: dataString)
                    }
                    let response = "{\"error\":0}"
                    connection.send(content: response.data(using: .utf8), completion: .contentProcessed({ error in
                        if let error = error {
                            print(error)
                        }
                    }))
                    receiveData()
                }
            })
        }
        
    }
    
    
}

//192.168.2.69:49159        DP4800 傳回資訊
//State: Preparing
//State: Ready
//Optional("POST /sendData HTTP/1.1\r\n")
//Optional("Host: 192.168.2.53\r\nContent-Type: application/json\r\nContent-Length: 214\r\n")
//Optional("\r\n{\"title\":\"measure\",\"model\":\"MS4980\",\"sn\":\"0\",\"total\":\"1\",\"packet\":[{\"index\":\"1\",\"id\":\"444557\",\"nid\":\"fddf\",\"tare_weight\":\"0.0kg\",\"net_weight\":\"81.7kg\",\"height\":\"160.0cm\",\"bmi\":\"31.9\",\"time\":\"2023-01-09 16:44:54\"}]}")
//2023-01-09 16:45:52.338415+0800 TCPServer[83029:15144607] [tcp] tcp_input [C4:1] flags=[R.] seq=7759, ack=3021553486, win=5840 state=CLOSE_WAIT rcv_nxt=7759, snd_una=3021553475
//ERROR! State not defined!
