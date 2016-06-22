//
//  QMServiceManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 5/22/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation
import TWMessageBarManager

/**
*  Implements user's memory/cache storing, error handling, show top bar notifications.
*/
class ServicesManager: QMServicesManager {
    
    var currentDialogID : String = ""
    
    var colors = [
        UIColor(red: 0.992, green:0.510, blue:0.035, alpha:1.000),
        UIColor(red: 0.039, green:0.376, blue:1.000, alpha:1.000),
        UIColor(red: 0.984, green:0.000, blue:0.498, alpha:1.000),
        UIColor(red: 0.204, green:0.644, blue:0.251, alpha:1.000),
        UIColor(red: 0.580, green:0.012, blue:0.580, alpha:1.000),
        UIColor(red: 0.396, green:0.580, blue:0.773, alpha:1.000),
        UIColor(red: 0.765, green:0.000, blue:0.086, alpha:1.000),
        UIColor.red(),
        UIColor(red: 0.786, green:0.706, blue:0.000, alpha:1.000),
        UIColor(red: 0.740, green:0.624, blue:0.797, alpha:1.000)
    ]
    
    private var contactListService : QMContactListService!
    var notificationService: NotificationService!
    //var lastActivityDate: NSDate!
    
    override init() {
        super.init()
        
        self.setupContactServices()
    }
    
    private func setupContactServices() {
        self.notificationService = NotificationService()
    }
    
    func handleNewMessage(message: QBChatMessage, dialogID: String) {
        
        print("handle new message called")
        
        if self.currentDialogID == dialogID {
            return
        }
        
        if message.senderID == self.currentUser()!.id {
            return
        }
        
        let dialog = self.chatService.dialogsMemoryStorage.chatDialog(withID: dialogID)
        var dialogName = "SA_STR_NEW_MESSAGE".localized
        
        if dialog!.type != .private {
            
            if dialog!.name != nil {
                dialogName = dialog!.name!
            }
    
        } else {
            
            if let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(dialog!.recipientID)) {
                dialogName = user.login!
            }
        }
        
        TWMessageBarManager.sharedInstance().hideAll()
        TWMessageBarManager.sharedInstance().showMessage(withTitle: dialogName, description: message.text, type: .info)

    }
    
    // MARK: Last activity date
    
    var lastActivityDate: NSDate? {
        get {
            let defaults = UserDefaults.standard()
            return defaults.value(forKey: "SA_STR_LAST_ACTIVITY_DATE".localized) as! NSDate?
        }
        set {
            let defaults = UserDefaults.standard()
            defaults.set(newValue, forKey: "SA_STR_LAST_ACTIVITY_DATE".localized)
            defaults.synchronize()
        }
    }

    // MARK: QMServiceManagerProtocol
    
    override func handleErrorResponse(_ response: QBResponse) {
        super.handleErrorResponse(response)
        
        if !self.isAuthorized() {
            return;
        }
        
        var errorMessage : String
        
        if response.status.rawValue == 502 {
            errorMessage = "SA_STR_BAD_GATEWAY".localized
        } else if response.status.rawValue == 0 {
            errorMessage = "SA_STR_NETWORK_ERROR".localized
        } else {
            
            errorMessage = (response.error?.error?.localizedDescription.replacingOccurrences(of: "(", with: "", options: .caseInsensitiveSearch, range: nil).replacingOccurrences(of: ")", with: "", options: .caseInsensitiveSearch, range: nil))!
        }
        
        
        TWMessageBarManager.sharedInstance().hideAll()
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "SA_STR_ERROR".localized, description: errorMessage, type: .error)
        
    }
    
    func downloadLatestUsers(success:(([QBUUser]?) -> Void)?, error:((NSError?) -> Void)?) {

//        let enviroment = Constants.QB_USERS_ENVIROMENT
        let searchUsertask = usersService.searchUsers(withTags: ["SvDev"])
        //why cannot use trailing closures? WIll cause 'ambiguous use of xxx issue'
        searchUsertask.continue({[unowned self] (task: BFTask!) -> AnyObject! in
            if (task.error != nil) {
                error?(task.error)
                return nil
            }
            
            success?(self.filteredUsersByCurrentEnvironment())
            
            return nil
        })
        
//        usersService.searchUsers(withTags: ["SvDev"]).continue {
//            [weak self] (task : BFTask!) -> AnyObject! in
//            if (task.error != nil) {
//                error?(task.error)
//                return nil
//            }
//            
//            success?(self?.filteredUsersByCurrentEnvironment())
//            
//            return nil
//        }
    }
    
    func color(forUser user:QBUUser) -> UIColor {
        
        let users = self.usersService.usersMemoryStorage.unsortedUsers()
        let userIndex = (users).index(of: self.usersService.usersMemoryStorage.user(withID: user.id)!)
        
        if userIndex < self.colors.count {
            return self.colors[userIndex!]
        } else {
            return UIColor.black()
        }
    }
    
    func filteredUsersByCurrentEnvironment() -> [QBUUser] {
        
//        let currentEnvironment = Constants.QB_USERS_ENVIROMENT
//        var containsString: String
//        
//        if (currentEnvironment == "qbqa") {
//            containsString = "qa"
//        } else {
//            containsString = currentEnvironment
//        }
        
        let unsortedUsers = self.usersService.usersMemoryStorage.unsortedUsers() 

//        let filteredUsers = unsortedUsers[0..<unsortedUsers.count].filter { (user: QBUUser) -> Bool in
//            return user.login?.lowercaseString.rangeOfString(containsString) != nil
//        }
//        
//        let sortedUsers = filteredUsers.sort({ (user1, user2) -> Bool in
//            return (user1.login! as NSString).compare(user2.login!, options:NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
//        })
        
        return unsortedUsers
    }
    
    // MARK: QMChatServiceDelegate
    
    
    override func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        super.chatService(chatService, didAddMessageToMemoryStorage: message, forDialogID: dialogID)
        self.handleNewMessage(message: message, dialogID: dialogID)
    }
    
}
