//
//  JSQRishMessage.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 4/1/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

class JSQRichMessage: JSQMessage {
    var idid: String
    
    init(qbChatMessage: QBChatMessage) {
        idid = qbChatMessage.ID!
        
        let isMedia = qbChatMessage.isMediaMessage()
        if !isMedia {
            super.init(senderId: "", senderDisplayName: "", date: NSDate(), text: "")
        } else {
            //don't care about media first
            super.init(senderId: "", senderDisplayName: "", date: NSDate(), media: nil)
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
