//
//  Constants.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


import Foundation

let kChatPresenceTimeInterval:TimeInterval = 45
let kDialogsPageLimit:UInt = 100
let kUsersLimit = 10
let kMessageContainerWidthPadding:CGFloat = 40.0

class Constants {
    
    class var QB_USERS_ENVIROMENT: String {
        
//#if DEBUG
        return "SvDev"
//#elseif QA
//        return "qbqa"
//#else
//    assert(false, "Not supported build configuration")
//    return ""
//#endif
        
    }
}
