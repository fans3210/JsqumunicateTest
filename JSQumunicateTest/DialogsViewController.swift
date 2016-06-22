//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit
import SVProgressHUD


class DialogTableViewCellModel: NSObject {
    
    var detailTextLabelText: String = ""
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?
    
    init(dialog: QBChatDialog) {
        super.init()
        
        if dialog.type == .private {
            
            self.detailTextLabelText = "SA_STR_PRIVATE".localized
            
            if dialog.recipientID == -1 {
                return
            }
            
            // Getting recipient from users service.
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(dialog.recipientID)) {
                self.textLabelText = recipient.login ?? recipient.email!
            }
            
        } else if dialog.type == .group {
            self.detailTextLabelText = "SA_STR_GROUP".localized
        } else {
            self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
        }
        
        if self.textLabelText.isEmpty {
            // group chat
            
            if let dialogName = dialog.name {
                self.textLabelText = dialogName
            }
        }
        
        // Unread messages counter label
        
        if (dialog.unreadMessagesCount > 0) {
            
            var trimmedUnreadMessageCount : String
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            
            self.unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            self.unreadMessagesCounterHiden = false
            
        } else {
            
            self.unreadMessagesCounterLabelText = nil
            self.unreadMessagesCounterHiden = true
        }
        
        // Dialog icon
        
        if dialog.type == .private {
            self.dialogIcon = UIImage(named: "user")
        } else {
            self.dialogIcon = UIImage(named: "group")
        }
    }
}

class DialogsViewController: UITableViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    
    private var didEnterBackgroundDate: NSDate?
    
    // MARK: - ViewController overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // calling awakeFromNib due to viewDidLoad not being called by instantiateViewControllerWithIdentifier
        self.navigationItem.title = ServicesManager.instance().currentUser()!.fullName!
        
        self.navigationItem.leftBarButtonItem = self.createLogoutButton()
        
        ServicesManager.instance().chatService.addDelegate(self)
        
        NotificationCenter.default().addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main()) { (notification: Notification) -> Void in
            
            if !QBChat.instance().isConnected() {
                SVProgressHUD.show(withStatus: "SA_STR_CONNECTING_TO_CHAT".localized)
            }
        }
        
        NotificationCenter.default().addObserver(self, selector: #selector(DialogsViewController.didEnterBackgroundNotification), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        if (QBChat.instance().isConnected()) {
            self.getDialogs()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            print("would go to chatvc")
//            if let jchatVC = segue.destinationViewController as? JChatViewController, sender = sender as? QBChatDialog {
//                jchatVC.dialog = sender
//                if let currentUserLogin = ServicesManager.instance().currentUser().login {
//                    let currentUserId = "\(ServicesManager.instance().currentUser().ID)"
//                    print("current user login is \(currentUserLogin), id is \(currentUserId)")
//                    jchatVC.senderDisplayName = currentUserId ?? "default user id"
//                    jchatVC.senderId = currentUserId ?? "default user id"
//                }
//                
//                
//            }
            if let ChatVC = segue.destinationViewController as? ChatVC, sender = sender as? QBChatDialog {
                if let currentUserLogin = ServicesManager.instance().currentUser()!.login {
                    let currentUserId = "\(ServicesManager.instance().currentUser()!.id)"
                    print("current user login is \(currentUserLogin), id is \(currentUserId)")
                    ChatVC.senderDisplayName = currentUserId ?? "default user id"
                    ChatVC.senderId = currentUserId ?? "default user id"
                    ChatVC.dialog = sender
                }
                
                
            }
        }
    }
    
    // MARK: - Notification handling
    
    func didEnterBackgroundNotification() {
        self.didEnterBackgroundDate = NSDate()
    }
    
    // MARK: - Actions
    
    func createLogoutButton() -> UIBarButtonItem {
        
        let logoutButton = UIBarButtonItem(title: "SA_STR_LOGOUT".localized, style: .plain, target: self, action: #selector(DialogsViewController.logoutAction))
        
        return logoutButton
    }
    
    @IBAction func logoutAction() {
        
        SVProgressHUD.show(withStatus: "SA_STR_LOGOUTING".localized)
        
        let logoutGroup: DispatchGroup = DispatchGroup()
        logoutGroup.enter()
        
        let deviceIdentifier: String = UIDevice.current().identifierForVendor!.uuidString
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { (response: QBResponse!) -> Void in
            //
            NSLog("success unsub push")
            logoutGroup.leave()
            }) { (error: QBError?) -> Void in
                //
                NSLog("push unsub failed")
                logoutGroup.leave()
        }
        
        ServicesManager.instance().lastActivityDate = nil
        
        
        //swift 3.0 style
        
        logoutGroup.notify(queue: DispatchQueue.main) { 
            [weak self] () -> Void in
            // Logouts from Quickblox, clears cache.
            if let strongSelf = self {
                ServicesManager.instance().logout {
                    NotificationCenter.default().removeObserver(strongSelf)
                    ServicesManager.instance().chatService.removeDelegate(strongSelf)
                    strongSelf.navigationController?.popViewController(animated: true)

                    SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
                }
                
            }
        }

        
        
        //swift 2.2 style
//        dispatch_group_notify(logoutGroup, dispatch_get_main_queue()) {
//            [weak self] () -> Void in
//            // Logouts from Quickblox, clears cache.
//            if let strongSelf = self {
//                ServicesManager.instance().logout {
//                    NotificationCenter.default().removeObserver(strongSelf)
//                    ServicesManager.instance().chatService.removeDelegate(strongSelf)
//                    strongSelf.navigationController?.popViewController(animated: true)
//                    
//                    SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
//                }
//
//            }
//        }
    }
    
    // MARK: - DataSource Action
    
    func getDialogs() {
        
        if (ServicesManager.instance().lastActivityDate != nil) {
            
            ServicesManager.instance().chatService.fetchDialogsUpdated(from: ServicesManager.instance().lastActivityDate! as Date, andPageLimit: kDialogsPageLimit, iterationBlock: { (response, dialogObjects, dialogsUsersIDs, stop) -> Void in
                //
                }, completionBlock: { (response: QBResponse!) -> Void in
                    //
                    if (ServicesManager.instance().isAuthorized() && response.isSuccess) {
                        ServicesManager.instance().lastActivityDate = NSDate()
                    }
            })
        }
        else {
            SVProgressHUD.show(withStatus: "SA_STR_LOADING_DIALOGS".localized)
            ServicesManager.instance().chatService.allDialogs(withPageLimit: kDialogsPageLimit, extendedRequest: nil, iterationBlock: { (response, dialogObjects, dialogsUsersIDs, stop) -> Void in
                //
                }, completion: { (response: QBResponse!) -> Void in
                    //
                    if (ServicesManager.instance().isAuthorized()) {
                        if (response.isSuccess) {
                            SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
                            ServicesManager.instance().lastActivityDate = NSDate()
                        }
                        else {
                            SVProgressHUD.showError(withStatus: "SA_STR_FAILED_LOAD_DIALOGS".localized)
                        }
                    }
            })
        }
    }
    
    // MARK: - DataSource
    
    static func dialogs() -> Array<QBChatDialog> {
        
        // Returns dialogs sorted by updatedAt date.
        return ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false) as Array<QBChatDialog>
    }
    
    // MARK: - UITableViewDataSource
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = DialogsViewController.dialogs().count
        
        return numberOfRowsInSection
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogcell", for: indexPath) as! DialogTableViewCell
        
        let chatDialog = DialogsViewController.dialogs()[indexPath.row]
        
        cell.tag = indexPath.row
        cell.dialogID = chatDialog.id!
        
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        
        cell.dialogLastMessage?.text = chatDialog.lastMessageText
        cell.dialogName?.text = cellModel.textLabelText
        cell.dialogTypeImage.image = cellModel.dialogIcon
        //        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        //        cell.unreadMessageCounterLabel.text = ""
        //        cell.unreadMessageCounterHolder.hidden = cellModel.unreadMessagesCounterHiden
        
        return cell
    }
    

    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dialog = DialogsViewController.dialogs()[indexPath.row]
        self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let dialog = DialogsViewController.dialogs()[indexPath.row]
            
            _ = AlertView(title:"SA_STR_WARNING".localized , message:"SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized , cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitle: ["SA_STR_DELETE".localized], didClick:{ (buttonIndex) -> Void in
                
                if buttonIndex != 1 {
                    return
                }
                
                SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized)
                
                let deleteDialogBlock = { (dialog: QBChatDialog!) -> Void in
                    
                    // Deletes dialog from server and cache.
                    
                    ServicesManager.instance().chatService.deleteDialog(withID: dialog.id!, completion: { (response: QBResponse!) -> Void in
                        
                        if response.isSuccess {
                            
                            SVProgressHUD.showSuccess(withStatus: "SA_STR_DELETED".localized)
                            
                        } else {
                            
                            SVProgressHUD.showError(withStatus: "SA_STR_ERROR_DELETING".localized)
                            print(response.error?.error)
                        }
                    })
                }
                
                if dialog.type == .private {
                    
                    deleteDialogBlock(dialog)
                    
                } else {
                    
                    let occupantIDs =  dialog.occupantIDs!.filter( {$0 != ServicesManager.instance().currentUser()!.id} )
                    
                    dialog.occupantIDs = occupantIDs
                    
                    // Notifies occupants that user left the dialog.
                    //                    ServicesManager.instance().chatService.sendMessageAboutUpdateDialog(dialog, withNotificationText: "User \(ServicesManager.instance().currentUser().login!) " + "SA_STR_USER_HAS_LEFT".localized, customParameters: nil, completion: { (error: NSError?) -> Void in
                    //                        deleteDialogBlock(dialog)
                    //                    })
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "SA_STR_DELETE".localized
    }
    
    
    // MARK: - QMChatServiceDelegate
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        self.tableView.reloadData()
    }
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogsInMemoryStorage dialogs: [QBChatDialog]) {
        
        self.tableView.reloadData()
    }
    
    func chatService(_ chatService: QMChatService, didAddChatDialogsToMemoryStorage chatDialogs: [QBChatDialog]) {
        
        self.tableView.reloadData()
    }
    
    func chatService(_ chatService: QMChatService, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog) {
        
        self.tableView.reloadData()
    }
    
    func chatService(_ chatService: QMChatService, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String) {
        
        self.tableView.reloadData()
    }
    
    func chatService(_ chatService: QMChatService, didAddMessagesToMemoryStorage messages: [QBChatMessage], forDialogID dialogID: String) {
        
        self.tableView.reloadData()
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        self.tableView.reloadData()
    }
    
    // MARK: QMChatConnectionDelegate
    
    func chatServiceChatDidAccidentallyDisconnect(_ chatService: QMChatService) {
        SVProgressHUD.showError(withStatus: "SA_STR_DISCONNECTED".localized)
    }
    
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized)
        self.getDialogs()
    }
    
    func chatService(_ chatService: QMChatService, chatDidNotConnectWithError error: NSError) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
    
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        SVProgressHUD.showSuccess(withStatus: "SA_STR_RECONNECTED".localized)
        self.getDialogs()
    }
}
