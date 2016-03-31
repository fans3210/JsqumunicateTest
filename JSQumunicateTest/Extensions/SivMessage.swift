//
//  QMChatMessage+Jsqable.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 3/31/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

class SivMessage: NSObject, QBChatMessagePresentable {
    
    var senderId: String
    var senderDisplayName: String
    var date: NSDate?
    var isMediaMessage: Bool
    var messageHash: Int {
        return self.hash
    }
    
    var id: String?
    
    //extra parameters from qbchatmessage

    var customParameters: [String : AnyObject]?
    var text: String?
    
    init(senderId: String, senderDisplayName: String, date: NSDate, isMediaMessage: Bool, id: String) {
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.date = date
        self.isMediaMessage = isMediaMessage
        self.id = id
        super.init()
    }
    
    init(qbmessage: QBChatMessage) {
        self.senderId = "\(qbmessage.senderID)"
        self.senderDisplayName = "default senderdisplayname"
        self.date = qbmessage.dateSent
        self.isMediaMessage = qbmessage.isMediaMessage()
        self.id = qbmessage.ID
        super.init()
    }
   
    
}
