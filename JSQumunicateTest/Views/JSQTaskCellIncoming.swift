//
//  JSQTaskCellIncoming.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 5/9/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import UIView_Shake

class JSQTaskCellIncoming: JSQMessagesCollectionViewCellIncoming {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var refuseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.blackColor()
    }
    @IBAction func acceptPressed(sender: UIButton) {
        print("accept")
        acceptButton.shake()
    }

    @IBAction func refusePressed(sender: UIButton) {
        print("refuse")
        refuseButton.shake()
    }
}
