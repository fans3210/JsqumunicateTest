//
//  TestVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 4/1/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit

class TestVC: JSQMessagesViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    var dialog: QBChatDialog?
    var messages = [JSQMessage]()
    var richMessages = [JSQRichMessage]()
    
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
        ServicesManager.instance().chatService.addDelegate(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        addMessage("foo", text: "123!")
//        // messages sent from local sender
//        addMessage(senderId, text: "sdfa!")
//        addMessage(senderId, text: "sdfsd!")
//        addMessage(senderId, text: "asfaslkdjflasdffasdfas")
        // animates the receiving of a new message on the view
        
//        generateRichMessages()
//        finishReceivingMessage()
        loadMessages()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    func addRichMessage(senderId: String, text: String) {
        let richMessage = JSQRichMessage(customParameters: [:], senderId: senderId, senderDisplayName: "sdfdsf", text: text)
        richMessages.append(richMessage)
    }
    
    func generateRichMessages() {
        addRichMessage(senderId, text: "sdfsdf111")
        addRichMessage(senderId, text: "sdfsadsfasdfd2222f")
        addRichMessage("dsf", text: "sdfsadsfas333dfdf")
        addRichMessage("f", text: "sdfsadsfasd44444fdf")
    }
    
    func loadMessages() {
        ServicesManager.instance().chatService.messagesWithChatDialogID(dialog?.ID) {[unowned self] response, messageObjects in
            if messageObjects.count > 0 {
                let messages = messageObjects as! [QBChatMessage]
                for message in messages {
                    let jsqRich = JSQRichMessage(qbChatMessage: message)
                    self.richMessages.append(jsqRich)
                }
                self.finishReceivingMessage()
            }
        }
    }
    
    
}

extension TestVC {
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
//        return messages[indexPath.item]
        return richMessages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
        return richMessages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
//        let message = messages[indexPath.item] // 1
//        if message.senderId == senderId { // 2
//            return outgoingBubble
//        } else { // 3
//            return incomingBubble
//        }
        
        let richMessage = richMessages[indexPath.item]
        if richMessage.senderId == senderId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}
