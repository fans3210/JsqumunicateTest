//
//  IncomingCallVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 5/16/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit

class IncomingCallVC: UIViewController {
    
    var session: QBRTCSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBRTCClient.instance().addDelegate(self)
        
    }
    
    func cleanUp() {
        QBRTCClient.instance().removeDelegate(self)
        QBRTCSoundRouter.instance().deinitialize()
    }

}

extension IncomingCallVC: QBRTCClientDelegate {
    func sessionDidClose(session: QBRTCSession!) {
        cleanUp()
    }
}
