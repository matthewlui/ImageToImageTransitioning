//
//  Transitioning.swift
//  CollectionImageToDetailTransition
//
//  Created by Matthew Lui on 2/4/2016.
//  Copyright © 2016 goldunderknees. All rights reserved.
//

import UIKit

public protocol ImageToImageTransitionImageViewProvider {
    func transitionImageView() -> UIImageView?
}

public protocol ImageToImageTransitionDestinationProvider {
    func imageViewTransitionWillBegin()
    func imageViewTransitionDidFinish()
    func imageViewTransitionDestinationFrame() -> CGRect
}

public class ImageToImageTransitioning :NSObject,UIViewControllerAnimatedTransitioning{
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Prepare what we need
        // If those dependence components don't even exist, we exit (rythm)
        guard let desVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
        let transitionView = transitionContext.containerView() else { return }
        // Both the source and destination ViewController should adopted the protocol we require, otherwise we can do nothing and be quiet (rythm)
        var srcVC : UIViewController
        guard let src = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else { return }
        srcVC = src
        if let nav = srcVC as? UINavigationController,
        let top = nav.topViewController{
            srcVC = top
        }
        guard let imageViewProvider = srcVC as? ImageToImageTransitionImageViewProvider else {return}
        guard let destinationProvider = desVC as? ImageToImageTransitionDestinationProvider else {return}
        
        //perform actual moves
        // Config our destination viewController first
        desVC.view.frame = transitionContext.finalFrameForViewController(desVC)
        // Prepare for alpha animation. Why alpha? becuase we are moving the imageView from A view to B view, keep B be static will help us a lot for reduce the computation and make sure an at least overall standard of the animation
        desVC.view.alpha = 0
        transitionView.addSubview(desVC.view)
        // Ok now the imageView
        // take a snapshot of the imageView we are going to move, instantly
        
        guard let originalImageView = imageViewProvider.transitionImageView() else {
            desVC.view.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            return
        }
        
        let snapShotImageView = originalImageView.snapshotViewAfterScreenUpdates(false)
        snapShotImageView.frame = transitionView.convertRect(originalImageView.frame, fromView: originalImageView.superview)
        transitionView.addSubview(snapShotImageView)
        // The replacement is ready, so we can hide the origin imageViewNow
        originalImageView.hidden = true
        
        destinationProvider.imageViewTransitionWillBegin()
        let destinationFrame = destinationProvider.imageViewTransitionDestinationFrame()
        
        let animation = {
            snapShotImageView.frame = destinationFrame
            desVC.view.alpha = 1
        }
        let completion = { (f:Bool) in
            if f {
                originalImageView.hidden = false
                destinationProvider.imageViewTransitionDidFinish()
                snapShotImageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        }
        // AnimationPart
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseInOut, animations:animation,completion: completion)
    }
    
    public func animationEnded(transitionCompleted: Bool) {
        
    }
    
}

public class ImageToImageTransitioningDelegate :NSObject, UIViewControllerTransitioningDelegate{
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImageToImageTransitioning()
    }
}





