//
//  TestVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 4/1/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit
import JSQMessagesViewController

//MARK: note: messages can be loaded from cache or memory or via internet

typealias SenderId = String

class TestVC: JSQMessagesViewController, QMChatConnectionDelegate {
    var dialog: QBChatDialog?
    var messages = [JSQMessage]()
    var richMessages = [JSQRichMessage]()
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingBubble: JSQMessagesBubbleImage!
    var typingTimer: NSTimer?
    
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubble = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.purpleColor())
        incomingBubble = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    private func setUserTypingAppearance() {
        //remove this restriction for now. just for testing a group chat with 2 people
        //because group chatting can be monitored in dashboard
        //a group chatting with 2 people, occupants number is 3 since admin is included
        if dialog?.type == .Private  || dialog?.occupantIDs?.count == 3 {
        
            dialog?.onUserIsTyping = {[unowned self] userId in
                guard ServicesManager.instance().currentUser()!.ID != userId else {
                    return
                }
                self.showTypingIndicator = true
                self.scrollToBottomAnimated(true)
            }

            
            
            dialog?.onUserStoppedTyping = {[unowned self] userId in
                guard ServicesManager.instance().currentUser()!.ID != userId else {
                    return
                }
                self.collectionView.performBatchUpdates({
                    self.showTypingIndicator = false
                    }, completion: nil)
                
            }
        }
    }
    
    
    //config other cells beside message cells, like tasks etc
    private func configCellsBesideMessageCells() {
        let jsqTaskCellIncomingNib = UINib(nibName: "JSQTaskCellIncoming", bundle: NSBundle.mainBundle())
        collectionView.registerNib(jsqTaskCellIncomingNib, forCellWithReuseIdentifier: JSQTaskCellIncoming.cellReuseIdentifier())
        
        let jsqTaskCellOutgoingNib = UINib(nibName: "JSQTaskCellOutgoing", bundle: NSBundle.mainBundle())
        collectionView.registerNib(jsqTaskCellOutgoingNib, forCellWithReuseIdentifier: JSQTaskCellOutgoing.cellReuseIdentifier())
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        senderId = "123"
//        senderDisplayName = "fans"

        title = dialog?.name
        setupBubbles()
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        ServicesManager.instance().chatService.addDelegate(self)
        
        //change the default settings
        ServicesManager.instance().chatService.chatMessagesPerPage = 100
        QMChatCache.instance()!.messagesLimitPerDialog = 100
        
        //toolbars
        
        
        
        setUserTypingAppearance()
        configCellsBesideMessageCells()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TestVC.sendStopTyping), name: UIApplicationWillResignActiveNotification, object: nil)
        
        loadMessages()

    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        ServicesManager.instance().currentDialogID = ""
        dialog?.clearTypingStatusBlocks()
    }
    
    
    private func storedInMemoryMessages() -> [JSQRichMessage]? {
        
        let messages = (ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID((dialog?.ID)!)).map {[unowned self] in
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
    
    
    private func loadMessages() {
        //load messages logic
        if let dialog = dialog {
            ServicesManager.instance().currentDialogID = dialog.ID! //this is used in service manager's handlenewmessage funcs, it will stop the twmessagebarcontroller being displayed in this page when new message comes from the user is just the one u r talking to
        }
        
        
        guard let messagesInMemory = storedInMemoryMessages() where messagesInMemory.count > 0 && richMessages.count == 0 else {
            retrieveMessagesFromCacheAndOL()
            return
        }
        //get from memory
        richMessages += messagesInMemory
        for message in richMessages {
            print("\(message.text) 🌑load from memory storage")
        }
        finishReceivingMessage()
        
        
    }
    
    
    //will not use loadearliermessages func, becuase it's just used for pagenation
    //this should be the first time when we got the message from internet
    private func retrieveMessagesFromCacheAndOL() {
        //this function load messages from both cache and network
        
        ServicesManager.instance().chatService.messagesWithChatDialogID((dialog?.ID)!) {[unowned self] response, messageObjects in
            
            print("response: \(response), messageObjects count \(messageObjects!.count)")
            
            if messageObjects!.count > 0 {
                
                let messages = (messageObjects!).map {[unowned self] in
                    self.mapQBChatToJSQRich($0)
                }
                
                for message in messages {
                    print("\(message.text) 👨‍👩‍👧‍👦load from Network)")
                    if !self.richMessages.contains(message) {
                        self.richMessages.append(message)
                    }
                }

                self.finishReceivingMessage()
               
            }
        }
    }
    

    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        print("did press send button")
        self.sendStopTyping()
        button.enabled = false
        
        let messageToBeSent = QBChatMessage()
        messageToBeSent.text = text
        let senderId = UInt(senderId)!
        messageToBeSent.senderID = senderId
        messageToBeSent.deliveredIDs = [senderId]
        messageToBeSent.readIDs = [senderId]
        messageToBeSent.dateSent = date
        
        ServicesManager.instance().chatService.sendMessage(messageToBeSent, toDialogID: (dialog?.ID)!, saveToHistory: true, saveToStorage: true) {[unowned self] error in
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
    
    private struct Commands {
        static let commandTask = "\\ttkk"
        static let commandTaskAccepted = "\\ttkka"
    }
    
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let richMessage = richMessages[indexPath.item]
        let isOutgoingMessage = richMessage.senderId == senderId
        
        if richMessage.text.containsString(Commands.commandTask) {
            if !isOutgoingMessage {
                return CGSizeMake(320, 154)
            } else {
                return CGSizeMake(320, 61)
            }
        } else {
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        }
    }
    
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let richMessage = richMessages[indexPath.item];
        let isOutgoingMessage = richMessage.senderId == senderId
        
        if richMessage.text.containsString(Commands.commandTask) {
            //special type of cell
            if !isOutgoingMessage {
                //is icoming
                let taskIncomingcell = collectionView.dequeueReusableCellWithReuseIdentifier(JSQTaskCellIncoming.cellReuseIdentifier(), forIndexPath: indexPath) as! JSQTaskCellIncoming
                taskIncomingcell.delegate = self
                taskIncomingcell.taskCellDelegate = self
                return taskIncomingcell
            } else {
                //ougoing task cell
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(JSQTaskCellOutgoing.cellReuseIdentifier(), forIndexPath: indexPath) as! JSQTaskCellOutgoing
                return cell
            }
        } else {
            //normal cell
            let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            return cell
        }
    }
    
//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print("select cell")
//    }
    
    
}


extension TestVC: JSQMessagesCollectionViewCellDelegate {
    func messagesCollectionViewCellDidTapAvatar(cell: JSQMessagesCollectionViewCell) {
        
    }
    
    func messagesCollectionViewCellDidTapMessageBubble(cell: JSQMessagesCollectionViewCell) {
        
    }
    
    func messagesCollectionViewCellDidTapCell(cell: JSQMessagesCollectionViewCell, atPosition position: CGPoint) {
        
        if cell is JSQTaskCellIncoming {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let taskDetailsPopVC = storyboard.instantiateViewControllerWithIdentifier("taskDetailsPop")
            taskDetailsPopVC.modalPresentationStyle = .Custom
            self.navigationController?.presentViewController(taskDetailsPopVC, animated: true, completion: nil)
        }
    }
    
    func messagesCollectionViewCell(cell: JSQMessagesCollectionViewCell, didPerformAction action: Selector, withSender sender: AnyObject) {
        
    }
    
    
}




//MARK: chat service delegate
extension TestVC: QMChatServiceDelegate {
    
    func chatService(chatService: QMChatService, didLoadMessagesFromCache messages: [QBChatMessage], forDialogID dialogID: String) {
        if self.dialog?.ID == dialogID {
            let messages = messages.map {[unowned self] in
                self.mapQBChatToJSQRich($0)
            }
            self.richMessages += messages
            finishReceivingMessage()
            
            for message in richMessages {
               print("\(message.text) 🍏load from cache")
            }
            
            
        }
    }
    
    func chatService(chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        //TODO: this delegate even in quickblox will be called multiple times. Quickblox use a method to replace the existing message to avoid duplication. We should do similar stuff
        //NOTE2: there is no problem in one to one chatting, prob happens in group chatting, I think it's because of the recipent id. in group chatting senderid = recipent id, in group, recipent id is 0? (guess), so we will add one constraint first, make sure only display message for senderid != recipentid
        
        if self.dialog?.ID == dialogID {
            // Insert message received from XMPP or self sent
            let message = JSQRichMessage(qbChatMessage: message)
            
//            avoid duplication

//            if(!self.richMessages.contains(message) && (UInt(message.senderId) != message.recipentID)) {
                self.richMessages.append(message)
//            }
            finishReceivingMessage()
            print("🌰did add message to memory storage, message senderid is\(message.senderId) recipentid is \(message.recipentID)")
        }
    }
    

}

//MARK: special type of cell delegates
extension TestVC: JSQTaskCellDelegate {
    func acceptButtonDidPressedForCell(cell: JSQTaskCellIncoming) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            print("accept, index is \(indexPath.item)")
//            let message = richMessages[indexPath.row]
//            message.qbChatMessage?.text = "sdf"
//            ServicesManager.instance().chatService.update
        }
    }
    
    func refuseButtonDidPressedForCell(cell: JSQTaskCellIncoming) {
        print("refuse")
    }
}



//MARK: textfield delegates
extension TestVC {
    
    private func sendBeginTyping() {
        if let dialog = dialog {
            dialog.sendUserIsTyping()
            print("send user is typing")
        }
    }
    
    func sendStopTyping() { //cannot be private because will be used as timer's selector
        if let dialog = dialog {
            
            if let timer = self.typingTimer {
                
                timer.invalidate()
            }
            self.typingTimer = nil
            dialog.sendUserStoppedTyping()
            print("send user stopped typing")
        }
    }
    
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard QBChat.instance().isConnected() else {
            return false //prevent typing
        }
        
        //when text changes, if timer is active, disable it and re-timing
        if let typingTimer = self.typingTimer {
            typingTimer.invalidate()
            self.typingTimer = nil
        } else {
            sendBeginTyping()
        }
        typingTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(TestVC.sendStopTyping), userInfo: nil, repeats: false)
        return true
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        super.textViewDidEndEditing(textView)

        guard QBChat.instance().isConnected() else {
            return
        }

        sendStopTyping() //normally is in viewwilldisappear case
    }
    
}
