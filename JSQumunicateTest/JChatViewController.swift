//
//  JChatViewController.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 3/30/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

class JChatViewController: JSQMessagesViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    var dialog: QBChatDialog?
    var messages = [QBChatMessage]()
    var jmessages = [JSQRichMessage]()
    var demoMessages = [JSQMessage]()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    /*
     note: typing, use typingindicator
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBubbles()
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        collectionView.backgroundColor = UIColor.grayColor()
        
        print("jchatvc viewdidload")
        
        if dialog?.type == .Private {
            //private, add typing detector
            dialog?.onUserIsTyping = { userId in
                
                if ServicesManager.instance().currentUser().ID == userId {
                    return
                }
                
                print("is typing")
                
            }
            
            dialog?.onUserStoppedTyping = { userId in
                if ServicesManager.instance().currentUser().ID == userId {
                    return
                }
                print("stopped typing")
                
            }
            
        }
        
        
        ServicesManager.instance().chatService.addDelegate(self)
        //        ServicesManager.instance().chatService.chatAttachmentService.delegate = self
        loadMessages()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.dataSource = self
        collectionView.delegate = self
        demoAddingMessage("fsf", text: "Hi")
        demoAddingMessage("fsf", text: "Hi sdaf")
        demoAddingMessage("fsf", text: "Hi asdf")
        demoAddingMessage("fsf", text: "H asfi")
        demoAddingMessage("fsf", text: "Hi sa")
        demoAddingMessage("fsf", text: "Hi asdf")
        finishReceivingMessage()
        collectionView.reloadData()
    }
    
    private func setupBubbles() {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.blueColor())
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.redColor())
    }
    

    
    func storedMessages() -> [QBChatMessage]? {
        return ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID(dialog?.ID) as? [QBChatMessage]
    }
    
    func loadMessages() {
        //load messages for dialog id
        ServicesManager.instance().chatService.messagesWithChatDialogID(dialog?.ID) {[unowned self] response, messageObjects in
            
            if messageObjects.count > 0 {
                self.messages += messageObjects as! [QBChatMessage]
                
                for message in self.messages {
                    print("qb message text is \(message.text)")
                    let jsqrich = JSQRichMessage(qbChatMessage: message)
                    print("jsqrich message is \(jsqrich)")
                    self.jmessages.append(jsqrich)
                }
            }
           print("self.collectionview, datasource is \(self.collectionView.dataSource), delagete is \(self.collectionView.delegate)")
            
        }
    }
    
    func demoAddingMessage(senderId: String, text: String) {
        let message = JSQMessage(senderId: senderId, displayName: "", text: text)
        demoMessages.append(message)
    }
    
}

////MARK: cv datasource
extension JChatViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jmessages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
//        print("in jsqmessagecollectionview datasource")
//        let qbMessage = messages[indexPath.item]
//        print("cv delegate qb message text is \(qbMessage.text)")
//        let jsqrich = JSQRichMessage(qbChatMessage: qbMessage)
//        print("cv delegate jsqrich message is \(jsqrich)")
//        return jsqrich
        
        return demoMessages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let jsqmessage = jmessages[indexPath.item]
        if jsqmessage.senderId == senderId {
            return outgoingBubbleImage
        }
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        cell.backgroundColor = UIColor.orangeColor()
        cell.textView.textColor = UIColor.purpleColor()
        return cell
        
        
    }
    
}
