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

protocol JSQTaskCellDelegate: class {
    func acceptButtonDidPressedForCell(cell: JSQTaskCellIncoming);
    func refuseButtonDidPressedForCell(cell: JSQTaskCellIncoming);
}

class JSQTaskCellIncoming: JSQMessagesCollectionViewCellIncoming {
    
    weak var taskCellDelegate: JSQTaskCellDelegate?

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var refuseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.blackColor()
    }
    @IBAction func acceptPressed(sender: UIButton) {
        
        acceptButton.shake(2, withDelta: 3) {[unowned self] in
            self.taskCellDelegate?.acceptButtonDidPressedForCell(self)
        }
    }

    @IBAction func refusePressed(sender: UIButton) {
        
        refuseButton.shake(2, withDelta: 3) {[unowned self] in
            self.taskCellDelegate?.refuseButtonDidPressedForCell(self)
        }
    }
}
