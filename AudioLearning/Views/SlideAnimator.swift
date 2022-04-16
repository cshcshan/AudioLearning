//
//  SlideAnimator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/10/21.
//  Copyright © 2019 cshan. All rights reserved.
//

import UIKit

class SlidePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var beforeAnimate: ((_ transitionContext: UIViewControllerContextTransitioning) -> Void)?
    var animating: ((_ transitionContext: UIViewControllerContextTransitioning) -> Void)?
    var completeAnimate: ((_ transitionContext: UIViewControllerContextTransitioning) -> Void)?

    private let animationDuration = TimeInterval(UINavigationController.hideShowBarDuration)

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        let containerWidth = containerView.frame.width
        containerView.addSubview(fromView)
        containerView.addSubview(toView)

        let offsetLeft = CGAffineTransform(translationX: -containerWidth, y: 0)
        let offsetRight = CGAffineTransform(translationX: containerWidth, y: 0)

        if let animate = beforeAnimate {
            animate(transitionContext)
        }

        toView.transform = offsetRight
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let self = self else { return }
            fromView.transform = offsetLeft
            toView.transform = CGAffineTransform.identity
            if let animating = self.animating {
                animating(transitionContext)
            }
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            if let animate = self.completeAnimate {
                animate(transitionContext)
            }
            fromView.transform = CGAffineTransform.identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class SlidePopAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var beforeAnimate: ((_ transitionContext: UIViewControllerContextTransitioning) -> Void)?
    var animating: ((_ transitionContext: UIViewControllerContextTransitioning) -> Void)?
    var completeAnimate: ((_ transitionContext: UIViewControllerContextTransitioning) -> Void)?

    private let animationDuration = TimeInterval(UINavigationController.hideShowBarDuration)

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }

        let containerView = transitionContext.containerView
        let containerWidth = containerView.frame.width
        containerView.addSubview(fromView)
        containerView.addSubview(toView)

        let offsetLeft = CGAffineTransform(translationX: -containerWidth, y: 0)
        let offsetRight = CGAffineTransform(translationX: containerWidth, y: 0)

        if let animate = beforeAnimate {
            animate(transitionContext)
        }

        toView.transform = offsetLeft
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            guard let self = self else { return }
            fromView.transform = offsetRight
            toView.transform = CGAffineTransform.identity
            if let animating = self.animating {
                animating(transitionContext)
            }
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            if let animate = self.completeAnimate {
                animate(transitionContext)
            }
            fromView.transform = CGAffineTransform.identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
