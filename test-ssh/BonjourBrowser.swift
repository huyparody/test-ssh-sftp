//
//  BonjourBrowser.swift
//  test-ssh
//
//  Created by Huy Trinh Duc on 26/03/2023.
//

import Foundation
import Network
import NMSSH

//class BonjourBrowser: NSObject, NetServiceBrowserDelegate {
//    var browser: NetServiceBrowser!
//    var devices: [String] = []
//    var netServices: [NetService] = []
//
//    override init() {
//        super.init()
//        self.browser = NetServiceBrowser()
//        self.browser.delegate = self
//        self.browser.searchForServices(ofType: "_ssh._tcp.", inDomain: "local.")
//    }
//
//    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
//        service.resolve(withTimeout: 5.0)
//        self.devices.append(service.hostName ?? service.name)
//        self.netServices.append(service)
//        if !moreComing {
//            print(self.netServices)
//        }
//    }
//
//    func getAllAvailableDevices() -> [String] {
//        return devices
//    }
//}

class BonjourScanner: NSObject, NetServiceBrowserDelegate {
    
    var browser: NetServiceBrowser!
    var devices = [NetService]()
    
    func startScanning() {
        browser = NetServiceBrowser()
        browser.delegate = self
        browser.searchForServices(ofType: "_ssh._tcp.", inDomain: "")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("Found device: \(service.name)")
        devices.append(service)
        if !moreComing {
            print("Finished scanning for devices")
            // Do something with the found devices, such as display in a table view
        }
        print(devices.count)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Error searching for services: \(errorDict)")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = devices.firstIndex(of: service) {
            print("Removed device: \(service.name)")
            devices.remove(at: index)
        }
    }
    
    func openSSH() {
        let devicesNameToHost = "\(devices[0].name.replacingOccurrences(of: "’", with: "").components(separatedBy: .whitespaces).joined(separator: "-")).\(devices[0].domain)"

        let session = NMSSHSession(host: devicesNameToHost, andUsername: "huyparody")
        session.connect()
        if session.isConnected {
            session.authenticate(byPassword: "/")
            if session.isAuthorized {
                // Successfully connected and authenticated
                print("connect success")
                
                let sftp = NMSFTP.connect(with: session)
                let directoryPath = "/"
                let directoryContents = sftp.contentsOfDirectory(atPath: directoryPath)?.forEach({print($0.filename)})
            }
            else {
                print("connect failed")
            }
        }
        
    }
    
}

