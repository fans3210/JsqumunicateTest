//
//  JSQRishMessage.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 4/1/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

class JSQRichMessage: JSQMessage {
    var id: String?
    var recipentID: UInt
    var customParameters: [String: AnyObject]?
    var dialogID: String?
    var qbChatMessage: QBChatMessage?

    init(qbChatMessage: QBChatMessage) {
        id = qbChatMessage.ID
        recipentID = qbChatMessage.recipientID
        
//        if let customParams = qbChatMessage.customParameters {
//            for (K, V) in customParams {
//                customParameters![K as! T] = V
//            }
//        }
        if let custParams = qbChatMessage.customParameters {
            customParameters = (custParams as NSDictionary) as? [String: AnyObject]
        }
        dialogID = qbChatMessage.dialogID
        
        //get sender displayName
        let currentUserId = "\(ServicesManager.instance().currentUser().ID)"
//            print("current user login is \(currentUserLogin), id is \(currentUserId)")
        let senderDisplayName = currentUserId ?? "default user id"
        
        
        //whether is media message
        let isMedia = qbChatMessage.isMediaMessage()
        if !isMedia {
            super.init(senderId: "\(qbChatMessage.senderID)", senderDisplayName: senderDisplayName, date:qbChatMessage.dateSent, text: qbChatMessage.text)
            print("init normal rich messsage, sender id is \(self.senderId)")
        } else {
            //don't care about media first
//            let testMediaData = JSQMediaItem()
            let photoMediaItem = JSQPhotoMediaItem()
            if let attachmentType = qbChatMessage.attachments?.first?.type {
                switch attachmentType {
                case "image":   
                    photoMediaItem.image = nil
                default:
                    break
                }
            }
            
            
            super.init(senderId: "\(qbChatMessage.senderID)", senderDisplayName: senderDisplayName, date: qbChatMessage.dateSent, media: photoMediaItem)
            print("init media message , senderid is \(self.senderId)")
            
        }
        self.qbChatMessage = qbChatMessage// use that for back up, when sending message, just use this variable to let qmchatservice to send
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

//func ==(lhs: JSQRichMessage, rhs: JSQRichMessage) -> Bool {
//    return (lhs.senderId == rhs.senderId) && (lhs.senderDisplayName == rhs.senderDisplayName)
//}

