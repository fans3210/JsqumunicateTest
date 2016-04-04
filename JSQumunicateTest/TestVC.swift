//
//  TestVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 4/1/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit

class TestVC: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingBubble: JSQMessagesBubbleImage!
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubble = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.purpleColor())
        incomingBubble = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        senderId = "123"
        senderDisplayName = "fans"

        title = "ChatChat"
        setupBubbles()
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addMessage("foo", text: "123!")
        // messages sent from local sender
        addMessage(senderId, text: "sdfa!")
        addMessage(senderId, text: "sdfsd!")
        addMessage(senderId, text: "asfaslkdjflasdffasdfas")
        // animates the receiving of a new message on the view
        finishReceivingMessage()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    func addJRichMessage(id: String, text: String) {
        
        
    }
    
    
}

extension TestVC {
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubble
        } else { // 3
            return incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}
