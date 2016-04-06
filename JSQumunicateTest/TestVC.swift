//
//  TestVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 4/1/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit

class TestVC: JSQMessagesViewController, QMChatConnectionDelegate {
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
        ServicesManager.instance().chatService.chatMessagesPerPage = 100
        QMChatCache.instance().messagesLimitPerDialog = 100
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
        if let storedMessages = storedMessages() where storedMessages.count > 0 && richMessages.count == 0 {
            richMessages += storedMessages
        }
        
        loadMessages()
//        loadEarlierMessages()
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
    
    func storedMessages() -> [JSQRichMessage]? {
        
        let messages = (ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID(dialog?.ID) as? [QBChatMessage])?.map({ qmChatMesssage -> JSQRichMessage in
            return JSQRichMessage(qbChatMessage: qmChatMesssage)
        })
        
        return messages
    }
    
    func loadMessages() {
        ServicesManager.instance().chatService.messagesWithChatDialogID(dialog?.ID) {[unowned self] response, messageObjects in
            
            print("response: \(response), messageObjects count \(messageObjects.count)")
            
            if messageObjects.count > 0 {
                let messages = (messageObjects as! [QBChatMessage]).map({ message -> JSQRichMessage in
                    return JSQRichMessage(qbChatMessage: message)
                })
                self.richMessages += messages
                self.finishReceivingMessage()
            }
        }
    }
    
    func loadEarlierMessages() {
        ServicesManager.instance().chatService.loadEarlierMessagesWithChatDialogID(dialog?.ID).continueWithBlock {[unowned self] task -> AnyObject? in
            if task.result!.count > 0 {
                let messages = (task.result as! [QBChatMessage]).map({ message -> JSQRichMessage in
                    return JSQRichMessage(qbChatMessage: message)
                })
                self.richMessages += messages
                self.finishReceivingMessage()
            }
            return nil
        }
    }
    
    
}


//MARK: chat service delegate
extension TestVC: QMChatServiceDelegate {
    
    func chatService(chatService: QMChatService!, didLoadMessagesFromCache messages: [QBChatMessage]!, forDialogID dialogID: String!) {
        if self.dialog?.ID == dialogID {
            let messages = messages.map({ message -> JSQRichMessage in
                return JSQRichMessage(qbChatMessage: message)
            })
            self.richMessages += messages
            finishReceivingMessage()
        }
    }
    
    func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        if self.dialog?.ID == dialogID {
            let message = JSQRichMessage(qbChatMessage: message)
            self.richMessages.append(message)
            finishReceivingMessage()
        }
    }
}


//MARK: collectionview delegates
//qmviewcontroller has more than 1 sections while jsqvc only have one, jsq use delegate methods to add timestamps

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
