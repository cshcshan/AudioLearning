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
    
    func addPulseAnimation() {
        guard layer.animation(forKey: "pulse") == nil else { return }
        let pulseAnimation = CASpringAnimation(keyPath: "transform.scale")
        pulseAnimation.mass = 10 // 值越大，動畫時間越長
        pulseAnimation.stiffness = 50 // 彈簧鋼度係數 0~100
        pulseAnimation.damping = 10.0 // 反彈次數
        pulseAnimation.initialVelocity = 0.5 // 初始速度
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatDuration = Double.infinity
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 1.5
        layer.add(pulseAnimation, forKey: "pulse")
    }
    
    func removePulseAnimation() {
        layer.removeAnimation(forKey: "pulse")
    }
}
