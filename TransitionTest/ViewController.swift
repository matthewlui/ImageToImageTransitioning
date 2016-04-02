//
//  ViewController.swift
//  TransitionTest
//
//  Created by Matthew Lui on 2/4/2016.
//  Copyright © 2016 goldunderknees. All rights reserved.
//

import UIKit
import ImageToImageTransitioning

class ViewController: UIViewController {

    @IBOutlet var tableView : UITableView!
    
    var interactCell : UITableViewCell? {
        guard let selectedIndex = tableView.indexPathForSelectedRow else { return nil }
        let cell = tableView.cellForRowAtIndexPath(selectedIndex)
        return cell
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let delegate = navigationController?.delegate where delegate === self{
               navigationController?.delegate = nil
        }
    }

}

extension ViewController : UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImageToImageTransitioning()
    }
}

extension ViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        guard let image = UIImage(named: "Logo_Melon") else { return cell }
        cell.imageView?.contentMode = .ScaleAspectFill
        cell.imageView?.image = image
        return cell
    }
}

extension ViewController :UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let storyboard = storyboard else { return }
        let toViewController = storyboard.instantiateViewControllerWithIdentifier("FooViewController")
        let delegate = ImageToImageTransitioningDelegate()
        toViewController.transitioningDelegate = delegate
        toViewController.modalPresentationStyle = .Custom
        navigationController?.pushViewController(toViewController, animated: true)
    }
    
}

//MARK: CollectionImageToDetailTransitionImageViewProvider
extension ViewController :ImageToImageTransitionImageViewProvider{
    func transitionImageView() -> UIImageView? {
        return interactCell?.imageView
    }
}

//MARK: FooViewController
class FooViewController : UIViewController {
    
    @IBOutlet var imageView:UIImageView!
    
    
    
    override func viewWillAppear(animated: Bool) {
        if let canReverse = self as? ImageToImageTransitionImageViewProvider{
            navigationController?.delegate = self
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let delegate = navigationController?.delegate where delegate === self{
            navigationController?.delegate = nil
        }
    }
    
}

extension FooViewController :UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImageToImageTransitioning()
    }
}

//MARK: CollectionImageToDetailTransitionDestinationProvider
extension FooViewController : ImageToImageTransitionDestinationProvider {
    func imageViewTransitionWillBegin() {
        imageView.hidden = true
    }
    func imageViewTransitionDidFinish() {
        imageView.hidden = false
    }
    func imageViewTransitionDestinationFrame() -> CGRect {
        view.layoutIfNeeded()
        return imageView.frame
    }
}

//MARK: Inverse Animation

extension ViewController :ImageToImageTransitionDestinationProvider{
    func imageViewTransitionWillBegin() {
        interactCell?.imageView?.hidden = true
    }
    func imageViewTransitionDidFinish() {
        interactCell?.imageView?.hidden = false
    }
    func imageViewTransitionDestinationFrame() -> CGRect {
        view.layoutIfNeeded()
        guard let interactCell = interactCell else { return CGRectZero }
        guard let imageView = interactCell.imageView else { return CGRectZero }
        return interactCell.convertRect(imageView.frame, toView: view)
    }
}

extension FooViewController :ImageToImageTransitionImageViewProvider{
    func transitionImageView() -> UIImageView? {
        return imageView
    }
}