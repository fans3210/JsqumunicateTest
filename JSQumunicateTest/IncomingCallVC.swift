//
//  IncomingCallVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 5/16/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit

protocol IncomingCallVCDelegate: class {
    
    func incomingCallVC(vc: IncomingCallVC, didAcceptSession session: QBRTCSession)
    
    func incomingCallVC(vc: IncomingCallVC, didRejectSession session: QBRTCSession)
    
}

class IncomingCallVC: UIViewController {
    
    var session: QBRTCSession!
    weak var delegate: IncomingCallVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBRTCClient.instance().addDelegate(self)
        
    }
    
    func cleanUp() {
        QBRTCClient.instance().removeDelegate(self)
        QBRTCSoundRouter.instance().deinitialize()
    }
    
//    private func acceptCall() {
//        let userInfo = ["acceptCall" : "userInfo"]
//        session.acceptCall(userInfo)
//        
//    }
    
    private func rejectCall() {
        session.rejectCall(nil)
        
    }

    @IBAction func accept(sender: UIButton) {

//        acceptCall()
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.incomingCallVC(self, didAcceptSession: session)
    }
    @IBAction func reject(sender: UIButton) {
        
        rejectCall()
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.incomingCallVC(self, didRejectSession: session)
    }
    
    
}

extension IncomingCallVC: QBRTCClientDelegate {
    func sessionDidClose(session: QBRTCSession!) {
        cleanUp()
    }
}
