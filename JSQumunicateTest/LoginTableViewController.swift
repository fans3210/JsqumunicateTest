//
//  LoginTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit
import SVProgressHUD
/**
 *  Default test users password
 */
let kTestUsersDefaultPassword = "x6Bt0VDy5"

class LoginTableViewController: UITableViewController, NotificationServiceDelegate {

    var users : [QBUUser]?
    
    // MARK: ViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetching users from cache.
        ServicesManager.instance().usersService.loadFromCache().continue ({[unowned self] (task : BFTask!) -> AnyObject! in
            if task.result!.count > 0 {
                
                self.setupUsers(users: ServicesManager.instance().filteredUsersByCurrentEnvironment())
                
            } else {
                
                SVProgressHUD.show(withStatus: "SA_STR_LOADING_USERS".localized)
                
                // Downloading users from Quickblox.
                
                ServicesManager.instance().downloadLatestUsers(success: { (users: [QBUUser]?) -> Void in
                    
                    SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
                    self.setupUsers(users: users!)
                    
                    }, error: { (error: NSError?) -> Void in
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                })
            }
            
            return nil;
        })
        
        if (ServicesManager.instance().currentUser() != nil) {
            ServicesManager.instance().currentUser()!.password = "12345678"
            SVProgressHUD.show(withStatus: "SA_STR_LOGGING_IN_AS".localized + ServicesManager.instance().currentUser()!.login!)
            // Logging to Quickblox REST API and chat.
            ServicesManager.instance().logIn(with: ServicesManager.instance().currentUser()!, completion:{
                [weak self] (success:Bool,  errorMessage: String?) -> Void in
                if let strongSelf = self {
                    if (success) {
                        strongSelf.registerForRemoteNotification()
                        SVProgressHUD.showSuccess(withStatus: "SA_STR_LOGGED_IN".localized)
                        
                        if (ServicesManager.instance().notificationService?.pushDialogID != nil) {
                            ServicesManager.instance().notificationService?.handlePushNotificationWithDelegate(delegate: self as! NotificationServiceDelegate)
                        }
                        else {
                            strongSelf.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                        }
                    } else {
                        SVProgressHUD.showError(withStatus: errorMessage)
                    }
                }
                })
        }
        
        self.tableView.reloadData()
    }
    
    func setupUsers(users: [QBUUser]) {
        self.users = users
        self.tableView.reloadData()
    }
    
    // MARK: NotificationServiceDelegate protocol
    
    func notificationServiceDidStartLoadingDialogFromServer() {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_DIALOG".localized)
    }
    
    func notificationServiceDidFinishLoadingDialogFromServer() {
        SVProgressHUD.dismiss()
    }
    
    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {
        print("notificationservicedidsucceedfetchingdialog")
//        let dialogsController: DialogsViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("DialogsViewController") as! DialogsViewController
//        let chatController: ChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
//        chatController.dialog = chatDialog
//
//        self.navigationController?.viewControllers = [dialogsController, chatController]
    }
    
    func notificationServiceDidFailFetchingDialog() {
        self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
    }
    
    // MARK: Actions
    
    func logInChatWithUser(user: QBUUser) {
        
        SVProgressHUD.show(withStatus: "SA_STR_LOGGING_IN_AS".localized + user.login!)

        // Logging to Quickblox REST API and chat.
        ServicesManager.instance().logIn(with: user, completion:{
            [unowned self] (success:Bool,  errorMessage: String?) -> Void in

            if (success) {
                self.registerForRemoteNotification()
                self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                SVProgressHUD.showSuccess(withStatus: "SA_STR_LOGGED_IN".localized)
                
            } else {
                
                SVProgressHUD.showError(withStatus: errorMessage)
            }

        })
    }
    
    // MARK: Remote notifications
    
    func registerForRemoteNotification() {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        
//            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
            UIApplication.shared().registerUserNotificationSettings(settings)
            UIApplication.shared().registerForRemoteNotifications()
        
    }
    

    

    
}


//tableview deleagets
extension LoginTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let _ = self.users {
            
            return self.users!.count
            
        } else {
            
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SA_STR_CELL_USER".localized, for: indexPath) as! UserTableViewCell
        
        let user = self.users![indexPath.row]
        
        cell.setColorMarkerText(text: String(indexPath.row + 1), color: UIColor.white())
        cell.userDescription = user.login
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
        
        let user = self.users![indexPath.row]
        user.password = "12345678"
        
        self.logInChatWithUser(user: user)
    }
}
