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
        
        let isMedia = qbChatMessage.isMediaMessage()
        if !isMedia {
            super.init(senderId: "\(qbChatMessage.senderID)", senderDisplayName: qbChatMessage.senderNick ?? "testSender", date:qbChatMessage.dateSent, text: qbChatMessage.text)
        } else {
            //don't care about media first
            let testMediaData = JSQMediaItem()
            super.init(senderId: "\(qbChatMessage.senderID)", senderDisplayName: qbChatMessage.senderNick ?? "testSender", date: qbChatMessage.dateSent, media: testMediaData)
            
        }
        
    }
    
    init(customParameters: [String: AnyObject]?, senderId:String, senderDisplayName: String, text: String) {
        recipentID = 12345
        self.customParameters = customParameters
        super.init(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), text: text)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
