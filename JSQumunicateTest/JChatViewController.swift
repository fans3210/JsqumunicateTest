//
//  JChatViewController.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 3/30/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

class JChatViewController: JSQMessagesViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    var dialog: QBChatDialog?
    var messages: [QBChatMessage] = []
    
    
    /*
     note: typing, use typingindicator
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //MARK: dangerous, just an attempt
        //attempt failed, might need to write a new viewcontroller(which is subclass of jsqmessageviewcontroller and takes jsqbmessagescollectionview in xib) to inherit from
        let qbCollectionView = collectionView as! JSQBMessagesCollectionView
        qbCollectionView.qb_dataSource = self
        
        ServicesManager.instance().chatService.addDelegate(self)
//        ServicesManager.instance().chatService.chatAttachmentService.delegate = self
        loadMessages()
        
    }
    
    func storedMessages() -> [QBChatMessage]? {
        return ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID(dialog?.ID) as? [QBChatMessage]
    }
    
    func loadMessages() {
        //load messages for dialog id
        ServicesManager.instance().chatService.messagesWithChatDialogID(dialog?.ID) {[unowned self] response, messageObjects in
            
            
        }
    }

}

//MARK: cv datasource
extension JChatViewController {
    
    func collectionView(collectionView: JSQMessagesCollectionView, qb_messageDataForItemAtIndexPath indexPath: NSIndexPath) -> QBChatMessagePresentable {
        let lastSection = collectionView.numberOfSections() - 1
        if indexPath.section == lastSection && indexPath.item == collectionView.numberOfItemsInSection(lastSection) - 1 {
            ServicesManager.instance().chatService?.loadEarlierMessagesWithChatDialogID(dialog?.ID).continueWithBlock{[unowned self] task in
                if task.result?.count > 0 {
                    self.messages += task.result as! [QBChatMessage]
                }
                return nil
            }
        }
        
        //get messages, don't care read unread first
        let qbmessage = messages[indexPath.row]
        print("get qbmessage \(qbmessage)")
        let sivmessage = SivMessage(qbmessage: qbmessage)
            
        return sivmessage
        
    }
}
