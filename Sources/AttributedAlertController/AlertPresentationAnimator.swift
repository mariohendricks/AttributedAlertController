//
//  AlertPresentationAnimator.swift
//
//  Portions of this file were created by Anton Poltoratskyi on 08.05.2021 as part of the NativeUI package.
//  Those portions are Copyright © 2021 Anton Poltoratskyi. All rights reserved.
//
//  Enhancements made by Mario Hendricks 14 May 2022. Those portions are Copyright 2022 by Mario Hendricks

import UIKit

final class AlertPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        if let alertViewController = fromViewController as? AttributedAlertController {
            animateHide(alertViewController, using: transitionContext)
            
        } else if let alertViewController = toViewController as? AttributedAlertController {
            animateShow(alertViewController, using: transitionContext)
        }
    }
    
    private func animateShow(_ alertViewController: AttributedAlertController, using transitionContext: UIViewControllerContextTransitioning) {
        guard let targetView = alertViewController.view else {
            return
        }
        transitionContext.containerView.addSubview(targetView)
        targetView.frame = transitionContext.containerView.bounds
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        let scale: CGFloat = 1.15
        let alertView = alertViewController.alertView
        alertView.transform = CGAffineTransform(scaleX: scale, y: scale)
        targetView.alpha = 0
        
        UIView.animate(withDuration: animationDuration, animations: {
            targetView.alpha = 1
            alertView.transform = .identity
            
        }, completion: { success in
            transitionContext.completeTransition(success)
        })
    }
    
    private func animateHide(_ alertViewController: AttributedAlertController, using transitionContext: UIViewControllerContextTransitioning) {
        guard let targetView = alertViewController.view else {
            return
        }
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        targetView.alpha = 1
        UIView.animate(withDuration: animationDuration, animations: {
            targetView.alpha = 0
            
        }, completion: { success in
            targetView.removeFromSuperview()
            transitionContext.completeTransition(success)
        })
    }
}
