//
//  ViewController.swift
//  test-ssh
//
//  Created by Huy Trinh Duc on 26/03/2023.
//

import UIKit
import GCDWebServer
import SSDPClient

class ViewController: UIViewController {
    
    let client = SSDPDiscovery()
    
    let bonjourBrowser = BonjourScanner()

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.client.delegate = self
//        self.client.discoverService()
        
        do {
            let server = try SSDPServer()
            try server.run()
        } catch {
            print("Error: \(error)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
//            self.bonjourBrowser.openSSH()
            
//            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
//            let webUploader = GCDWebUploader(uploadDirectory: documentsPath)
//            do {
//                try webUploader.start(options: [GCDWebServerOption_AutomaticallySuspendInBackground: false,
//                                                                            GCDWebServerOption_Port: 8080])
//            }
//            catch {
//                print("Error")
//            }
//
//            print("Visit \(String(describing: webUploader.serverURL)) in your web browser")
        }
        
    }
    

}
extension ViewController: SSDPDiscoveryDelegate {
    
    func ssdpDiscoveryDidStart(_ discovery: SSDPDiscovery) {
        print("did start \(discovery)")
    }
    
    func ssdpDiscoveryDidFinish(_ discovery: SSDPDiscovery) {
        print("did finish: \(discovery)")
    }
    
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscoverService service: SSDPService) {
        print("did discover \(discovery) \(service.uniqueServiceName)")
    }
    
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
