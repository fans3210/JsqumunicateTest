//
//  LocalVideoView.swift
//  JSQumunicateTest
//
//  Created by YAO DONG LI on 5/17/16.
//  Copyright © 2016 YAO DONG LI. All rights reserved.
//

import UIKit

protocol LocalVideoViewDelegate: class {
    func localVideoView (localVideoView: LocalVideoView, didPressedSwitchButton button: UIButton)
}

class LocalVideoView: UIView {
    
    var videoLayer: AVCaptureVideoPreviewLayer
    var containerView: UIView
    
    init(previewLayer: AVCaptureVideoPreviewLayer, frame: CGRect) {
        
        videoLayer = previewLayer
        videoLayer.frame = frame
        containerView = UIView(frame: frame)
        super.init(frame: frame)
        
        containerView.backgroundColor = UIColor.clearColor()
        containerView.layer.insertSublayer(videoLayer, atIndex: 0)
        insertSubview(containerView, atIndex: 0)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func setFrame(frame: CGRect) {
//        super.setFrame
//    }
}
