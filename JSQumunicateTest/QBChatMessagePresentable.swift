//
//  QBChatMessagePresentable.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 3/31/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

protocol QBChatMessagePresentable {
    var senderId: String { get }
    var senderDisplayName: String { get }
    var date : NSDate? { get }
    var isMediaMessage: Bool { get }
    var messageHash: Int { get }
    
    var customParameters: [String: AnyObject]? { get }
    var text: String? { get }
//   add later var media
    
}
