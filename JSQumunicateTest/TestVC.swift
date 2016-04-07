//
//  TestVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 4/1/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit

//MARK: note: messages can be loaded from cache or memory or via internet

typealias SenderId = String

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
//        senderId = "123"
//        senderDisplayName = "fans"

        title = "ChatChat"
        setupBubbles()
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        ServicesManager.instance().chatService.addDelegate(self)
        
        //change the default settings
        ServicesManager.instance().chatService.chatMessagesPerPage = 100
        QMChatCache.instance().messagesLimitPerDialog = 100
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        
        if let storedMessages = storedInMemoryMessages() where storedMessages.count > 0 && richMessages.count == 0 {
            richMessages += storedMessages
            finishReceivingMessage()
            return
        }
        
        loadMessagesOL()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    private func storedInMemoryMessages() -> [JSQRichMessage]? {
        
        let messages = (ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID(dialog?.ID) as? [QBChatMessage])?.map {[unowned self] in
            self.mapQBChatToJSQRich($0)
        }
        
        return messages
    }
    
    //if jsqmessage is a media message, config the bubble direction becuase it's bubble init is different from normal text message
    //this map added media ownership configs
    private func mapQBChatToJSQRich(qbChatMessage: QBChatMessage) -> JSQRichMessage {

        let richMessage = JSQRichMessage(qbChatMessage: qbChatMessage)
        
        if richMessage.isMediaMessage {
            let photoMediaItem = richMessage.media as! JSQPhotoMediaItem
            photoMediaItem.appliesMediaViewMaskAsOutgoing = richMessage.senderId == self.senderId
        }
        
        return richMessage
    
    }
    

    
    
    //will not use loadearliermessages func, becuase it's just used for pagenation
    //this should be the first time when we got the message from internet
    private func loadMessagesOL() {
        ServicesManager.instance().chatService.messagesWithChatDialogID(dialog?.ID) {[unowned self] response, messageObjects in
            
            print("response: \(response), messageObjects count \(messageObjects.count)")
            
            if messageObjects.count > 0 {

                let messages = (messageObjects as! [QBChatMessage]).map {[unowned self] in
                    self.mapQBChatToJSQRich($0)
                }
                
                self.richMessages += messages
                self.finishReceivingMessage()
            }
        }
    }
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        print("did press send button")
        let messageToBeSent = QBChatMessage()
        messageToBeSent.text = text
        let senderId = UInt(senderId)!
        messageToBeSent.senderID = senderId
        messageToBeSent.deliveredIDs = [senderId]
        messageToBeSent.readIDs = [senderId]
        messageToBeSent.dateSent = date
        
        ServicesManager.instance().chatService.sendMessage(messageToBeSent, toDialogID: dialog?.ID, saveToHistory: true, saveToStorage: true) {[unowned self] error in
            guard error == nil else {
                return print("sending message error: \(error)")
            }
            print("message sent successfully")
            self.finishSendingMessage()
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("did press accessory button")
    }
}

//MARK: collectionview delegates
//qmviewcontroller has more than 1 sections while jsqvc only have one, jsq use delegate methods to add timestamps

extension TestVC {
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return richMessages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
        return richMessages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
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
    
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
//
//        
//        return cell
//    }
    
}


//MARK: chat service delegate
extension TestVC: QMChatServiceDelegate {
    
    func chatService(chatService: QMChatService!, didLoadMessagesFromCache messages: [QBChatMessage]!, forDialogID dialogID: String!) {
        if self.dialog?.ID == dialogID {
            let messages = messages.map {[unowned self] in
                self.mapQBChatToJSQRich($0)
            }
            self.richMessages += messages
            finishReceivingMessage()
            print("🍏did load messages from cache")
        }
    }
    
    func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        
        //TODO: this delegate even in quickblox will be called multiple times. Quickblox use a method to replace the existing message to avoid duplication. We should do similar stuff
        //NOTE2: there is no problem in one to one chatting, prob happens in group chatting, I think it's because of the recipent id. in group chatting senderid = recipent id, in group, recipent id is 0? (guess), so we will add one constraint first, make sure only display message for senderid != recipentid
        
        if self.dialog?.ID == dialogID {
            // Insert message received from XMPP or self sent
            let message = JSQRichMessage(qbChatMessage: message)
            
            //avoid duplication

            if(!self.richMessages.contains(message) && (UInt(message.senderId) != message.recipentID)) {
                self.richMessages.append(message)
            }
            finishReceivingMessage()
            print("🌰did add message to memory storage, message senderid is\(message.senderId) recipentid is \(message.recipentID)")
        }
    }
}
