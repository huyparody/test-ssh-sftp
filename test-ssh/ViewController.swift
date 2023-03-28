//
//  ViewController.swift
//  test-ssh
//
//  Created by Huy Trinh Duc on 26/03/2023.
//

import UIKit
import GCDWebServer

class ViewController: UIViewController {
    
    let bonjourBrowser = BonjourScanner()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bonjourBrowser.startScanning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.bonjourBrowser.openSSH()
            
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

