//
//  ExtensionUIView.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/10.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

extension UIView {
    
    func addWiggleAnimation() {
        guard layer.animation(forKey: "wiggle") == nil else { return }
        let wiggleAnimation = CABasicAnimation(keyPath: "transform.rotation")
        wiggleAnimation.autoreverses = true
        wiggleAnimation.repeatDuration = Double.infinity
        wiggleAnimation.duration = 0.1
        wiggleAnimation.fromValue = NSNumber(value: -1 * Double.pi / 180.0)
        wiggleAnimation.toValue = NSNumber(value: 1 * Double.pi / 180.0)
        layer.add(wiggleAnimation, forKey: "wiggle")
    }
    
    func removeWiggleAnimation() {
        layer.removeAnimation(forKey: "wiggle")
    }
}
