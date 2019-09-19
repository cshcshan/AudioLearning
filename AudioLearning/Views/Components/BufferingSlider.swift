//
//  BufferingSlider.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/18.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class BufferingSlider: UISlider {
    
    let bufferProgressView = UIProgressView(progressViewStyle: .default)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        maximumTrackTintColor = .clear
        bufferProgressView.frame = self.bounds
        bufferProgressView.backgroundColor = .clear
        bufferProgressView.isUserInteractionEnabled = false
        bufferProgressView.progressTintColor = UIColor.black.withAlphaComponent(0.6)
        bufferProgressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.6)
        bufferProgressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bufferProgressView)
        
        let left = NSLayoutConstraint(item: bufferProgressView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: bufferProgressView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: bufferProgressView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0.75)
        self.addConstraints([left, right, centerY])
        
        sendSubviewToBack(bufferProgressView)
    }
}
