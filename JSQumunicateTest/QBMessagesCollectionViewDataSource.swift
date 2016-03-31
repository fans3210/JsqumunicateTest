//
//  QBMessagesCollectionViewDataSource.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 3/31/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

protocol QBMessagesCollectionViewDataSource: class {
//    var senderDisplayName: String { get }
//    var senderId: String { get }

    func collectionView(collectionView: JSQMessagesCollectionView, qb_messageDataForItemAtIndexPath indexPath: NSIndexPath) -> QBChatMessagePresentable
    
    func collectionView(collectionView: JSQMessagesCollectionView, qb_messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource
    
    func collectionView(collectionView: JSQMessagesCollectionView, qb_avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource

}

extension QBMessagesCollectionViewDataSource {
    func collectionView(collectionView: JSQMessagesCollectionView, qb_messageDataForItemAtIndexPath indexPath: NSIndexPath) -> QBChatMessagePresentable {
        assert(false, "no, required method not implemented \(#function)")
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView, qb_messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageBubbleImageDataSource {
        assert(false, "no, required method not implemented \(#function)")
    }
    
    func collectionView(collectionView: JSQMessagesCollectionView, qb_avatarImageDataForItemAtIndexPath indexPath: NSIndexPath) -> JSQMessageAvatarImageDataSource {
        assert(false, "no, required method not implemented \(#function)")
    }
}
