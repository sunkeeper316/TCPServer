

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lbIP: UILabel!
    @IBOutlet weak var lbShow: UILabel!
//    var tcpServer : TcpServer?
    var isStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        TcpServer.startServer(at: 5001)
//        TcpServer.shared.
    }
    override func viewDidAppear(_ animated: Bool) {
//        if let ip = UIDevice.current.getIpAddress() {
//            lbIP.text = ip
//            print(ip)
////            run(ip: ip)
////            TcpConnect.run()
//        }
        let ips = UIDevice.current.getIPv4Addresses()
        for ip in ips {
            
            lbIP.text! += "\(ip)\n"
        }
    }
    
    @IBAction func clickListener(_ sender: UIButton) {
        if isStart {
            isStart = false
            TcpServer.cencelServer()
            sender.setTitle("Listener", for: .normal)
        }else {
            isStart = true
            TcpServer.startServer(at: 2158)
            
            sender.setTitle("cencel", for: .normal)
        }
    }
    
    
//    func run(ip:String) {
//        let m = TcpConnect(hostName: ip, port: 2158)
//        m.start()
//    }


}

