//
//  AppDelegate.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 3/28/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit


//let kQBApplicationID:UInt = 38736
//let kQBAuthKey = "ApHFwfKqODE7PRU"
//let kQBAuthSecret = "XwWfcuLm68PyC9X"
//let kQBAccountKey = "9j18zPi5YsKUugPkmFm4"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private struct QBAppConfigs {
        static let kQBQpplicationId: UInt = 38736
        static let kQBAuthKey = "ApHFwfKqODE7PRU"
        static let kQBAuthSecret = "XwWfcuLm68PyC9X"
        static let kQBAccountKey = "9j18zPi5YsKUugPkmFm4"
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.setApplicationID(QBAppConfigs.kQBQpplicationId)
        QBSettings.setAuthKey(QBAppConfigs.kQBAuthKey)
        QBSettings.setAuthSecret(QBAppConfigs.kQBAuthSecret)
        QBSettings.setAccountKey(QBAppConfigs.kQBAccountKey)
        
        // Enables Quickblox REST API calls debug console output.
        QBSettings.setLogLevel(QBLogLevel.Nothing)
        
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
//        QBSettings.setChatDNSLookupCacheEnabled(true);
        
        
        //webrtc settings
        QBRTCClient.initializeRTC()
        
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

