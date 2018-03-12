//
//  UIViewControllerExt.swift
//  Tindog
//
//  Created by Doyle on 12/03/18.
//  Copyright © 2018 Doyle. All rights reserved.
//
import UIKit

extension UIViewController{
    
    func registerForKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShowNotification(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func keyboardWillShowNotification(notification:NSNotification){
        if (view.frame.origin.y >= 0){
            setViewMovedUp(movedUp: true, notification: notification)
        }else if (self.view.frame.origin.y < 0){
            setViewMovedUp(movedUp: false, notification: notification)
        }
    }
    
    @objc func keyboardDidShowNotification(notification:NSNotification){
        
    }
    
    @objc func keyboardWillHideNotification(notification:NSNotification){
        if (view.frame.origin.y >= 0){
            setViewMovedUp(movedUp: true, notification: notification)
        }else if (self.view.frame.origin.y < 0){
            setViewMovedUp(movedUp: false, notification: notification)
        }
    }
    
    @objc func setScrollViewInset(movedUp:Bool, scrollView:UIScrollView, scrollToBottom:Bool = false, notification:NSNotification){
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            if let keyboardFrame = endFrame{
                                if (movedUp){
                                    scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.height, 0)
                                }else{
                                    scrollView.contentInset = .zero
                                }
                                
                                if scrollToBottom {
                                    let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                                    if(bottomOffset.y > 0) {
                                        scrollView.setContentOffset(bottomOffset, animated: true)
                                    }
                                }
                            }
                            self.view.layoutIfNeeded()
            },
                           completion: nil)
        }
    }
    
    func setViewMovedUp(movedUp:Bool, notification:NSNotification){
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            var viewFrame = self.view.frame
                            if let keyboardFrame = endFrame{
                                if (movedUp){
                                    viewFrame.origin.y -= keyboardFrame.size.height
                                }else{
                                    viewFrame.origin.y = 0
                                }
                            }
                            self.view.frame = viewFrame
                            self.view.layoutIfNeeded()
            },
                           completion: nil)
        }
    }
}
