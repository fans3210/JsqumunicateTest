//
//  ChatVC.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 4/1/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit
import JSQMessagesViewController

//MARK: note: messages can be loaded from cache or memory or via internet

typealias SenderId = String

class ChatVC: JSQMessagesViewController, QMChatConnectionDelegate {
    
    
    var dialog: QBChatDialog?
    var messages = [JSQMessage]()
    var richMessages = [JSQRichMessage]()
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingBubble: JSQMessagesBubbleImage!
    var typingTimer: Timer?
    private var currentSession: QBRTCSession?
    
    private var previousCvWidth: CGFloat = 0.0
    
    lazy var toolbarAlertVC: UIAlertController = {
        let alertVC = UIAlertController(title: "Action", message: "Select One", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let videoCallAction = UIAlertAction(title: "Video Call", style: .default) {[unowned self] _ in
            
            guard let dialog = self.dialog else {
                return
            }
            let oppoentIds = dialog.occupantIDs?.filter {
                $0 != dialog.userID && $0 != ServicesManager.instance().currentUser()!.id //temporarily solution
            }

            let newSession = QBRTCClient.instance().createNewSession(withOpponents: oppoentIds, with: .video)
            print("create session with oppoentIds \(oppoentIds)")
            
            self.currentSession = newSession
            
            //go to private videochat vc
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let privateVideoChatVC = self.storyboard?.instantiateViewController(withIdentifier: "privateVideoChat") as? PrivateVideoChatVC {
                privateVideoChatVC.session = self.currentSession
                self.present(privateVideoChatVC, animated: true, completion: nil)
            }
        }
        
        let audioCallAction = UIAlertAction(title: "Audio Call", style: .default, handler: { _ in
            
        })
        
        alertVC.addAction(videoCallAction)
        alertVC.addAction(audioCallAction)
        alertVC.addAction(cancelAction)
        
        return alertVC
    }()
    
    
    
    private func setupBubbles() {
        //video call handler

        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubble = factory?.outgoingMessagesBubbleImage(
            with: UIColor.purple())
        incomingBubble = factory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func setUserTypingAppearance() {
        //remove this restriction for now. just for testing a group chat with 2 people
        //because group chatting can be monitored in dashboard
        //a group chatting with 2 people, occupants number is 3 since admin is included
        if dialog?.type == .private  || dialog?.occupantIDs?.count == 3 {
        
            dialog?.onUserIsTyping = {[unowned self] userId in
                guard ServicesManager.instance().currentUser()!.id != userId else {
                    return
                }
                self.showTypingIndicator = true
                self.scrollToBottom(animated: true)
            }

            
            
            dialog?.onUserStoppedTyping = {[unowned self] userId in
                guard ServicesManager.instance().currentUser()!.id != userId else {
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
        let jsqTaskCellIncomingNib = UINib(nibName: "JSQTaskCellIncoming", bundle: Bundle.main())
        collectionView.register(jsqTaskCellIncomingNib, forCellWithReuseIdentifier: JSQTaskCellIncoming.cellReuseIdentifier())
        
        let jsqTaskCellOutgoingNib = UINib(nibName: "JSQTaskCellOutgoing", bundle: Bundle.main())
        collectionView.register(jsqTaskCellOutgoingNib, forCellWithReuseIdentifier: JSQTaskCellOutgoing.cellReuseIdentifier())
    }
    
    private func configVideoCall() {
        QBRTCClient.instance().add(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        senderId = "123"
//        senderDisplayName = "fans"

        title = dialog?.name
        setupBubbles()
        // No avatars
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        ServicesManager.instance().chatService.addDelegate(self)
        
        //change the default settings
        ServicesManager.instance().chatService.chatMessagesPerPage = 100
        QMChatCache.instance()!.messagesLimitPerDialog = 100
        
        
        
        
        setUserTypingAppearance()
        configCellsBesideMessageCells()
        
        //config Videocall
        configVideoCall()

        
        //config vc
        
        previousCvWidth = collectionView.frame.width
        collectionView.backgroundColor = UIColor.black()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default().addObserver(self, selector: #selector(ChatVC.sendStopTyping), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        loadMessages()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if collectionView.frame.width != previousCvWidth {
            
            //save frame value from next comparison
            previousCvWidth = collectionView.frame.width
            let context = JSQMessagesCollectionViewFlowLayoutInvalidationContext()
            context.invalidateFlowLayoutMessagesCache = true
            collectionView.collectionViewLayout.invalidateLayout(with: context)
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default().removeObserver(self)
        
        ServicesManager.instance().currentDialogID = ""
        dialog?.clearTypingStatusBlocks()
    }
    
    
    private func storedInMemoryMessages() -> [JSQRichMessage]? {
        
        let messages = (ServicesManager.instance().chatService.messagesMemoryStorage.messages(withDialogID: (dialog?.id)!)).map {[unowned self] in
            self.mapQBChatToJSQRich(qbChatMessage: $0)
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
            ServicesManager.instance().currentDialogID = dialog.id! //this is used in service manager's handlenewmessage funcs, it will stop the twmessagebarcontroller being displayed in this page when new message comes from the user is just the one u r talking to
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
    //this should be the first time when we got the  message from internet
    private func retrieveMessagesFromCacheAndOL() {
        //this function load messages from both cache and network
        
        ServicesManager.instance().chatService.messages(withChatDialogID: (dialog?.id)!) {[unowned self] response, messageObjects in
            
            print("response: \(response), messageObjects count \(messageObjects!.count)")
            
            if messageObjects!.count > 0 {
                
                let messages = (messageObjects!).map {[unowned self] in
                    self.mapQBChatToJSQRich(qbChatMessage: $0)
                }
                
                for message in messages {
                    print("\(message.text) 👨‍👩‍👧‍👦load from Network)")
                    if !self.richMessages.contains(message) {
                        self.richMessages.append(message)
                    }
                }

                self.finishReceivingMessage()//should move this line out of the function, add completion handler
               
            }
        }
    }
    

    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        print("did press send button")
        self.sendStopTyping()
        button.isEnabled = false
        
        let messageToBeSent = QBChatMessage()
        messageToBeSent.text = text
        let senderId = UInt(senderId)!
        messageToBeSent.senderID = senderId
        messageToBeSent.deliveredIDs = [senderId]
        messageToBeSent.readIDs = [senderId]
        messageToBeSent.dateSent = date
        
        ServicesManager.instance().chatService.send(messageToBeSent, toDialogID: (dialog?.id)!, saveToHistory: true, saveToStorage: true) {[unowned self] error in
            guard error == nil else {
                
                return print("sending message error: \(error)")
            }
            print("message sent successfully")
            
            self.finishSendingMessage()
            
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("did press accessory button")
        self.present(toolbarAlertVC, animated: true, completion: nil)
    }

}


//MARK: video call delegates
extension ChatVC: QBRTCClientDelegate {
    
    func didReceiveNewSession(_ session: QBRTCSession!, userInfo: [NSObject : AnyObject]!) {
        print("🐲🐲did receive new session")
        guard let _ = currentSession else {
            QBRTCSoundRouter.instance().initialize()
            currentSession = session
            if let incomingCallVC = storyboard?.instantiateViewController(withIdentifier: "IncomingCall") as? IncomingCallVC {
                incomingCallVC.session = currentSession
                incomingCallVC.delegate = self
                self.present(incomingCallVC, animated: true, completion: nil)
            }
            return
        }
        
        let userInfo = ["reject" : "busy"]
        session.rejectCall(userInfo)

    }
    
    
    func sessionDidClose(_ session: QBRTCSession!) {
        print("🌰🌰🌰session did close")
    }
    
}





//MARK: incomingCallVC delegate
extension ChatVC: IncomingCallVCDelegate {
    func incomingCallVC(vc: IncomingCallVC, didAcceptSession session: QBRTCSession) {
        if let privateVideoChatVC = self.storyboard?.instantiateViewController(withIdentifier: "privateVideoChat") as? PrivateVideoChatVC {
            currentSession = session
            privateVideoChatVC.session = self.currentSession
            self.present(privateVideoChatVC, animated: true, completion: nil)
        }
    }
    
    func incomingCallVC(vc: IncomingCallVC, didRejectSession session: QBRTCSession) {
        currentSession = nil
    }
}





//MARK: collectionview delegates
//qmviewcontroller has more than 1 sections while jsqvc only have one, jsq use delegate methods to add timestamps

extension ChatVC {
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return richMessages[indexPath.item!]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
        return richMessages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let richMessage = richMessages[indexPath.item!]
        if richMessage.senderId == senderId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private struct Commands {
        static let commandTask = "\\ttkk"
        static let commandTaskAccepted = "\\ttkka"
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let richMessage = richMessages[indexPath.item!]
        _ = richMessage.senderId == senderId
        
//        if richMessage.text == Commands.commandTask {
//            if !isOutgoingMessage {
//                return CGSizeMake(320, 154)
//            } else {
//                return CGSizeMake(320, 61)
//            }
//        } else {
//            if indexPath.row == richMessages.count - 1 {
//                print("collectionview final cell size is \(super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)), final cell content is \(richMessage.text)")
//            }
//            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        
        return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
//        }
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let richMessage = richMessages[indexPath.item!]
        _ = richMessage.senderId == senderId
        
//        if richMessage.text == Commands.commandTask {
//            //special type of cell
//            if !isOutgoingMessage {
//                //is icoming
//                let taskIncomingcell = collectionView.dequeueReusableCellWithReuseIdentifier(JSQTaskCellIncoming.cellReuseIdentifier(), forIndexPath: indexPath) as! JSQTaskCellIncoming
//                taskIncomingcell.delegate = self
//                taskIncomingcell.taskCellDelegate = self
//                return taskIncomingcell
//            } else {
//                //ougoing task cell
//                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(JSQTaskCellOutgoing.cellReuseIdentifier(), forIndexPath: indexPath) as! JSQTaskCellOutgoing
//                return cell
//            }
//        } else {
            //normal cell
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            return cell
//        }
    }
    
//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print("select cell")
//    }
    
    
}


extension ChatVC: JSQMessagesCollectionViewCellDelegate {
    
    
    
    
    func messagesCollectionViewCellDidTapAvatar(_ cell: JSQMessagesCollectionViewCell!) {
        
    }
    
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: JSQMessagesCollectionViewCell!) {
        
    }
    
    func messagesCollectionViewCellDidTap(_ cell: JSQMessagesCollectionViewCell!, atPosition position: CGPoint) {

        if cell is JSQTaskCellIncoming {
    //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let taskDetailsPopVC = storyboard?.instantiateViewController(withIdentifier: "taskDetailsPop") {
                taskDetailsPopVC.modalPresentationStyle = .custom
                    self.navigationController?.present(taskDetailsPopVC, animated: true, completion: nil)
            }
        }
    }
    
//    func messagesCollectionViewCellDidTapCell(cell: JSQMessagesCollectionViewCell!, atPosition position: CGPoint) {
//        
//        if cell is JSQTaskCellIncoming {
////            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let taskDetailsPopVC = storyboard?.instantiateViewController(withIdentifier: "taskDetailsPop") {
//                taskDetailsPopVC.modalPresentationStyle = .custom
//                	self.navigationController?.present(taskDetailsPopVC, animated: true, completion: nil)
//            }
//        }
//    }
    
    func messagesCollectionViewCell(_ cell: JSQMessagesCollectionViewCell!, didPerformAction action: Selector!, withSender sender: AnyObject!) {
        
    }
    
    
    
}




//MARK: chat service delegate
extension ChatVC: QMChatServiceDelegate {
    
    func chatService(_ chatService: QMChatService, didLoadMessagesFromCache messages: [QBChatMessage], forDialogID dialogID: String) {
        if self.dialog?.id == dialogID {
            let messages = messages.map {[unowned self] in
                self.mapQBChatToJSQRich(qbChatMessage: $0)
            }
            self.richMessages += messages
            finishReceivingMessage()
            
            for message in richMessages {
               print("\(message.text) 🍏load from cache")
            }
            
            
        }
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        //TODO: this delegate even in quickblox will be called multiple times. Quickblox use a method to replace the existing message to avoid duplication. We should do similar stuff
        //NOTE2: there is no problem in one to one chatting, prob happens in group chatting, I think it's because of the recipent id. in group chatting senderid = recipent id, in group, recipent id is 0? (guess), so we will add one constraint first, make sure only display message for senderid != recipentid
        
        if self.dialog?.id == dialogID {
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
extension ChatVC: JSQTaskCellDelegate {
    func acceptButtonDidPressedForCell(cell: JSQTaskCellIncoming) {
        if let indexPath = collectionView.indexPath(for: cell) {
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
extension ChatVC {
    
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
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
        typingTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ChatVC.sendStopTyping), userInfo: nil, repeats: false)
        return true
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)

        guard QBChat.instance().isConnected() else {
            return
        }

        sendStopTyping() //normally is in viewwilldisappear case
    }
    
}
