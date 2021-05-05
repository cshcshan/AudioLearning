//
//  EpisodeAnimator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/21.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

final class EpisodePushAnimator: SlidePushAnimator {
    
    override init() {
        super.init()
        
        var containerView: UIView!
        var transitionImgView: UIImageView?
        var fromImageView: UIImageView?
        var toImageView: UIImageView?
        var imgViewTransform = CGAffineTransform.identity
        
        beforeAnimate = { transitionContext in
            guard let fromVC = transitionContext.viewController(forKey: .from) as? EpisodeListViewController,
                let toVC = transitionContext.viewController(forKey: .to) as? EpisodeDetailViewController,
                let fromView = transitionContext.view(forKey: .from),
                let toView = transitionContext.view(forKey: .to) else { return }
            
            containerView = transitionContext.containerView
            
            if let fromCell = fromVC.selectedCell, let fromImgView = fromCell.photoImageView, let toImgView = toVC.photoImageView {
                fromImageView = fromImgView
                toImageView = toImgView
                fromImgView.alpha = 0
                toImgView.alpha = 0
                fromView.layoutIfNeeded()
                toView.layoutIfNeeded()
                
                let fromImgViewFrame = fromImgView.convert(fromImgView.bounds, to: fromView)
                let toImgViewFrame = toImgView.convert(toImgView.bounds, to: toView)
                let transitionImageViewFrame = CGRect(x: fromImgViewFrame.minX + fromView.frame.minX,
                                                      y: fromImgViewFrame.minY + fromView.frame.minY,
                                                      width: fromImgViewFrame.width,
                                                      height: fromImgViewFrame.height)
                transitionImgView = UIImageView(image: fromImgView.image)
                transitionImgView!.frame = transitionImageViewFrame
                containerView.addSubview(transitionImgView!)
                
                let offsetX = toImgViewFrame.midX - fromImgViewFrame.midX
                let offsetY = toImgViewFrame.midY - fromImgViewFrame.midY
                imgViewTransform = CGAffineTransform(translationX: offsetX, y: offsetY)
                
                let scaleX = toImgViewFrame.width / fromImgViewFrame.width
                let scaleY = toImgViewFrame.height / fromImgViewFrame.height
                imgViewTransform = imgViewTransform.scaledBy(x: scaleX, y: scaleY)
            }
        }
        
        animating = { transitionContext in
            if let img = transitionImgView {
                img.transform = imgViewTransform
            }
        }
        
        completeAnimate = { transitionContext in
            transitionImgView?.removeFromSuperview()
            if let fromImgView = fromImageView {
                fromImgView.alpha = 1
            }
            if let toImgView = toImageView {
                toImgView.alpha = 1
            }
        }
    }
}

final class EpisodePopAnimator: SlidePopAnimator {
    
    override init() {
        super.init()
        
        var containerView: UIView!
        var transitionImgView: UIImageView?
        var fromImageView: UIImageView?
        var toImageView: UIImageView?
        var imgViewTransform = CGAffineTransform.identity
        
        beforeAnimate = { transitionContext in
            guard let fromVC = transitionContext.viewController(forKey: .from) as? EpisodeDetailViewController,
                let toVC = transitionContext.viewController(forKey: .to) as? EpisodeListViewController,
                let fromView = transitionContext.view(forKey: .from),
                let toView = transitionContext.view(forKey: .to) else { return }
            
            containerView = transitionContext.containerView
            
            if let fromImgView = fromVC.photoImageView, let toCell = toVC.selectedCell, let toImgView = toCell.photoImageView {
                fromImageView = fromImgView
                toImageView = toImgView
                fromImgView.alpha = 0
                toImgView.alpha = 0
                fromView.layoutIfNeeded()
                toView.layoutIfNeeded()
                
                let fromImgViewFrame = fromImgView.convert(fromImgView.bounds, to: fromView)
                let toImgViewFrame = toImgView.convert(toImgView.bounds, to: toView)
                let transitionImageViewFrame = CGRect(x: fromImgViewFrame.minX + fromView.frame.minX,
                                                      y: fromImgViewFrame.minY + fromView.frame.minY,
                                                      width: fromImgViewFrame.width,
                                                      height: fromImgViewFrame.height)
                transitionImgView = UIImageView(image: fromImgView.image)
                transitionImgView!.frame = transitionImageViewFrame
                containerView.addSubview(transitionImgView!)
                
                let offsetX = toImgViewFrame.midX - fromImgViewFrame.midX
                let offsetY = toImgViewFrame.midY - fromImgViewFrame.midY
                imgViewTransform = CGAffineTransform(translationX: offsetX, y: offsetY)
                
                let scaleX = toImgViewFrame.width / fromImgViewFrame.width
                let scaleY = toImgViewFrame.height / fromImgViewFrame.height
                imgViewTransform = imgViewTransform.scaledBy(x: scaleX, y: scaleY)
            }
        }
        
        animating = { transitionContext in
            if let img = transitionImgView {
                img.transform = imgViewTransform
            }
        }
        
        completeAnimate = { transitionContext in
            transitionImgView?.removeFromSuperview()
            if let fromImgView = fromImageView {
                fromImgView.alpha = 1
            }
            if let toImgView = toImageView {
                toImgView.alpha = 1
            }
        }
    }
}
