//
//  VideoChatVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 5/16/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit


class PrivateVideoChatVC: UIViewController {
    
    var session: QBRTCSession!
    var cameraCapture: QBRTCCameraCapture!
    var isOffer: Bool = false
    var localVideoView: LocalVideoView!
    var remoteVideoView: QBRTCRemoteVideoView!
    
    @IBOutlet weak var localVideoViewContainer: UIView!
    
    @IBOutlet weak var remoteVideoViewContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if session.conferenceType == .video {
            
            cameraCapture = QBRTCCameraCapture(videoFormat: QBRTCVideoFormat.default(), position: .back)
            
            configLocalVideoView()
            
            cameraCapture.startSession()
            
            
        }
        
        let inicatorId = session.initiatorID
        isOffer = (ServicesManager.instance().currentUser()?.id == inicatorId) ?? false
        QBRTCClient.instance().add(self)
        
        QBRTCSoundRouter.instance().initialize()
        

        
//        isOffer ? startCall() : acceptCall()
        if isOffer {
            startCall()
        } else {
            print("------------->accept call instead of start call")
            acceptCallInPrivateChatVC()
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    private func configLocalVideoView() {
        if session?.conferenceType == .video {
            //config local video view
            let localVideoView = LocalVideoView(previewLayer: cameraCapture.previewLayer, frame: localVideoViewContainer.frame)
            localVideoView.contentMode = .scaleAspectFit
            self.localVideoView = localVideoView
            localVideoViewContainer.addSubview(self.localVideoView)
        }
        
    }
    
    private func configRemoteVideoView(userId: NSNumber) {
        if session?.conferenceType == .video {
            
            let remoteVideoView = QBRTCRemoteVideoView(frame: remoteVideoViewContainer.frame)
            remoteVideoViewContainer.backgroundColor = UIColor.blue()
            remoteVideoView.backgroundColor = UIColor.orange()
            remoteVideoView.contentMode = .scaleAspectFit
            
            let remoteVideoTrack = session.remoteVideoTrack(withUserID: userId)
            remoteVideoView.setVideoTrack(remoteVideoTrack)
            
            self.remoteVideoView = remoteVideoView
            
            remoteVideoViewContainer.addSubview(remoteVideoView)

        }
    }
    
    
    private func startCall() {
        let userInfo = ["startCall" : "userInfo"]
        session.startCall(userInfo)
        print("<-------------start call")
    }
    
    //accept call is handled by incoming view controller or not??
    private func acceptCallInPrivateChatVC() {
        let userInfo = ["acceptCall" : "userInfo"]
        session.acceptCall(userInfo)
//        print("accept call")
    }

    @IBAction func dismiss(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: qbrtcclientdelegate
extension PrivateVideoChatVC: QBRTCClientDelegate {
    
    func session(session: QBRTCSession!, initializedLocalMediaStream mediaStream: QBRTCMediaStream!) {
        if session == self.session {
            session.localMediaStream.videoTrack.videoCapture = cameraCapture
        }
    }
    
    func session(session: QBRTCSession!, startedConnectingToUser userID: NSNumber!) {
        print("🌕 session start connecting to user \(userID)")
    }
    
    func session(session: QBRTCSession!, connectionClosedForUser userID: NSNumber!) {
        print("🌚 session connection closed for user \(userID)")
    }
    
    func session(session: QBRTCSession!, disconnectedFromUser userID: NSNumber!) {
        print("🌑 disconnect from user \(userID)")
    }
    
    func session(session: QBRTCSession!, disconnectedByTimeoutFromUser userID: NSNumber!) {
        print("🌑 disconnected by timeout from user \(userID)")
    }
    
    func session(session: QBRTCSession!, connectionFailedForUser userID: NSNumber!) {
        print("🌰 connection failed for user \(userID)")
    }
    
    func session(session: QBRTCSession!, userDidNotRespond userID: NSNumber!) {
        if session == self.session {
            print("user not respond")
        }
    }
    
    func session(session: QBRTCSession!, acceptedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        if session == self.session {
            print("accepted by user")
        }
    }
    
    func session(session: QBRTCSession!, rejectedByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        if session == self.session {
            print("rejected by user")
        }
    }
    
    func session(session: QBRTCSession!, hungUpByUser userID: NSNumber!, userInfo: [NSObject : AnyObject]!) {
        if session == self.session {
            print("hung up by user")
        }
    }
    
    func session(session: QBRTCSession!, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack!, fromUser userID: NSNumber!) {
        if session == self.session {
            //config remoteview
//            configRemoteVideoView(userID)
            configRemoteVideoView(userId: userID)

            
        }
    }
}























