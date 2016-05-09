//
//  LoginTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

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
        ServicesManager.instance().usersService.loadFromCache().continueWithBlock {[unowned self] (task : BFTask!) -> AnyObject! in
            if task.result!.count > 0 {
                
                self.setupUsers(ServicesManager.instance().filteredUsersByCurrentEnvironment())
                
            } else {
                
                SVProgressHUD.showWithStatus("SA_STR_LOADING_USERS".localized)
                
                // Downloading users from Quickblox.
                ServicesManager.instance().downloadLatestUsers({ (users: [QBUUser]!) -> Void in
                    
                    SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
                    self.setupUsers(users)
                    
                    }, error: { (error: NSError!) -> Void in
                        
                        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                })
            }
            
            return nil;
        }
        
        if (ServicesManager.instance().currentUser() != nil) {
            ServicesManager.instance().currentUser()!.password = "12345678"
            SVProgressHUD.showWithStatus("SA_STR_LOGGING_IN_AS".localized + ServicesManager.instance().currentUser()!.login!)
            // Logging to Quickblox REST API and chat.
            ServicesManager.instance().logInWithUser(ServicesManager.instance().currentUser()!, completion:{
                [weak self] (success:Bool,  errorMessage: String?) -> Void in
                if let strongSelf = self {
                    if (success) {
                        strongSelf.registerForRemoteNotification()
                        SVProgressHUD.showSuccessWithStatus("SA_STR_LOGGED_IN".localized)
                        
                        if (ServicesManager.instance().notificationService?.pushDialogID != nil) {
                            ServicesManager.instance().notificationService?.handlePushNotificationWithDelegate(self as! NotificationServiceDelegate)
                        }
                        else {
                            strongSelf.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                        }
                    } else {
                        SVProgressHUD.showErrorWithStatus(errorMessage)
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
        SVProgressHUD.showWithStatus("SA_STR_LOADING_DIALOG".localized)
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
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
    }
    
    // MARK: Actions
    
    func logInChatWithUser(user: QBUUser) {
        
        SVProgressHUD.showWithStatus("SA_STR_LOGGING_IN_AS".localized + user.login!)

        // Logging to Quickblox REST API and chat.
        ServicesManager.instance().logInWithUser(user, completion:{
            [unowned self] (success:Bool,  errorMessage: String?) -> Void in

            if (success) {
                self.registerForRemoteNotification()
                self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                SVProgressHUD.showSuccessWithStatus("SA_STR_LOGGED_IN".localized)
                
            } else {
                
                SVProgressHUD.showErrorWithStatus(errorMessage)
            }

        })
    }
    
    // MARK: Remote notifications
    
    func registerForRemoteNotification() {
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        
    }
    

    

    
}


//tableview deleagets
extension LoginTableViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let _ = self.users {
            
            return self.users!.count
            
        } else {
            
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_USER".localized, forIndexPath: indexPath) as! UserTableViewCell
        
        let user = self.users![indexPath.row]
        
        cell.setColorMarkerText(String(indexPath.row + 1), color: UIColor.whiteColor())
        cell.userDescription = user.login
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        let user = self.users![indexPath.row]
        user.password = "12345678"
        
        self.logInChatWithUser(user)
    }
}
