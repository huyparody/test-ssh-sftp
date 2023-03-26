//
//  ViewController.swift
//  test-ssh
//
//  Created by Huy Trinh Duc on 26/03/2023.
//

import UIKit

class ViewController: UIViewController {
    
    let bonjourBrowser = BonjourScanner()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bonjourBrowser.startScanning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.bonjourBrowser.openSSH()
        }
        
        
        
//        LocalNetworkAuthorization().requestAuthorization { vlaue in
////            print(vlaue)
//        }
        
        // Do any additional setup after loading the view.
        
//        print(bonjourBrowser.getAllAvailableDevices())
        
    }


}

