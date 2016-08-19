//
//  UIAlertView+Block.swift
//  UIAlertViewBlocks
//
//  Created by Drew on 16/8/17.
//  Copyright © 2016年 Drew. All rights reserved.
//

/**
    UIActionSheet的类扩展，使用block来代替实现代理方法完成回调
 */

import UIKit

extension UIAlertView {
    
    private struct AssociatedKey {
        static var UIAlertViewOriginalDelegateKey  = "UIAlertViewOriginalDelegateKey"
        static var UIAlertViewBlockKey = "UIAlertViewTapBlockKey"
    }
    
    typealias UIAlertViewBlock = (alertView: UIAlertView)->Void
    typealias UIAlertViewCompletionBlock = (alertView: UIAlertView, buttonIndex : Int)->Void
    
    // 定义block类，每个Block对应一个代理方法
    class Block {
        var tapBlock : UIAlertViewCompletionBlock?
        var willPresentBlock : UIAlertViewBlock?
        var didPresentBlock : UIAlertViewBlock?
        var willDismissBlock : UIAlertViewCompletionBlock?
        var didDismissBlock : UIAlertViewCompletionBlock?
        var cancelBlock : UIAlertViewBlock?
        var shouldEnableFirstOtherButtonBlock : ((alertView: UIAlertView)->Bool)?
    }
    
    // 利用runtime为UIAlertView添加block属性
    private var block : Block? {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewBlockKey) {
                return value as? Block
            }
            return nil
        }
        set (newValue) {
            self.checkAlertViewDelegate()
            if let _ = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewBlockKey) {
                objc_setAssociatedObject(self, &AssociatedKey.UIAlertViewBlockKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            objc_setAssociatedObject(self, &AssociatedKey.UIAlertViewBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 构造方法
    convenience init(title : String,
                   message : String,
                     style : UIAlertViewStyle,
         cancelButtonTitle : String,
         otherButtonTitles : [String],
                  tapBlock : UIAlertViewCompletionBlock?) {
        self.init(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        
        if otherButtonTitles.count != 0 {
            for str in otherButtonTitles {
                self.addButtonWithTitle(str)
            }
        }
        if let tapBlock = tapBlock {
            let blockMgr = self.block ?? Block()
            blockMgr.tapBlock = tapBlock
            self.block = blockMgr
        }
    }
    
    // 类方法：定义并展示alertView
    class func showWith(title : String,
                      message : String,
                        style : UIAlertViewStyle,
            cancelButtonTitle : String,
            otherButtonTitles : [String],
                     tapBlock : UIAlertViewCompletionBlock?) -> UIAlertView {
        
        let alertView = UIAlertView(title: title, message: message, style: style, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, tapBlock: tapBlock)
        alertView.show()
        return alertView
    }
    
    class func showWith(title : String,
                      message : String,
            cancelButtonTitle : String,
            otherButtonTitles : [String],
                     tapBlock : UIAlertViewCompletionBlock?) -> UIAlertView {
        return UIAlertView.showWith(title, message: message, style: .Default, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: otherButtonTitles, tapBlock: tapBlock)
    }
    
    // 检查是否有设置代理
    func checkAlertViewDelegate() {
        
        if self.delegate == nil {
            self.delegate = self
        } else if !self.delegate!.isEqual(self) {
            objc_setAssociatedObject(self, &AssociatedKey.UIAlertViewOriginalDelegateKey, self.delegate, .OBJC_ASSOCIATION_ASSIGN)
            self.delegate = self
        }
    }
    
    // 为alertView添加各代理方法对应的block
    func tapBlock(tapBlock: UIAlertViewCompletionBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.tapBlock = tapBlock
        self.block = blockMgr
    }
    func willDismissBlock(willDismissBlock: UIAlertViewCompletionBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.willDismissBlock = willDismissBlock
        self.block = blockMgr
    }
    func didDismissBlock(didDismissBlock: UIAlertViewCompletionBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.didDismissBlock = didDismissBlock
        self.block = blockMgr
    }
    func willPresentBlock(willPresentBlock: UIAlertViewBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.willPresentBlock = willPresentBlock
        self.block = blockMgr
    }
    func didPresentBlock(didPresentBlock: UIAlertViewBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.didPresentBlock = didPresentBlock
        self.block = blockMgr
    }
    func cancelBlock(cancelBlock: UIAlertViewBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.cancelBlock = cancelBlock
        self.block = blockMgr
    }
    func shouldEnableFirstOtherButtonBlock(shouldEnableFirstOtherButtonBlock: (alertView: UIAlertView)->Bool) {
        let blockMgr = self.block ?? Block()
        blockMgr.shouldEnableFirstOtherButtonBlock = shouldEnableFirstOtherButtonBlock
        self.block = blockMgr
    }
}

extension UIAlertView : UIAlertViewDelegate {
    
    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {

        if let completion = alertView.block?.tapBlock {
            completion(alertView: alertView, buttonIndex: buttonIndex)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewOriginalDelegateKey) as? UIAlertViewDelegate {
            originalDelegate.alertView?(alertView, clickedButtonAtIndex: buttonIndex)
        }
    }
    
    public func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if let completion = alertView.block?.willDismissBlock {
            completion(alertView: alertView, buttonIndex: buttonIndex)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewOriginalDelegateKey) as? UIAlertViewDelegate {
            originalDelegate.alertView?(alertView, willDismissWithButtonIndex: buttonIndex)
        }
    }
    
    public func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if let completion = alertView.block?.didDismissBlock {
            completion(alertView: alertView, buttonIndex: buttonIndex)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewOriginalDelegateKey) as? UIAlertViewDelegate {
            originalDelegate.alertView?(alertView, didDismissWithButtonIndex: buttonIndex)
        }
    }
    
    public func willPresentAlertView(alertView: UIAlertView) {
        if let block = alertView.block?.willPresentBlock {
            block(alertView: alertView)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewBlockKey) as? UIAlertViewDelegate {
            originalDelegate.willPresentAlertView?(alertView)
        }
    }
    
    public func didPresentAlertView(alertView: UIAlertView) {
        if let block = alertView.block?.didPresentBlock {
            block(alertView: alertView)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewBlockKey) as? UIAlertViewDelegate {
            originalDelegate.didPresentAlertView?(alertView)
        }
    }
    
    public func alertViewCancel(alertView: UIAlertView) {
        if let block = alertView.block?.cancelBlock {
            block(alertView: alertView)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewBlockKey) as? UIAlertViewDelegate {
            originalDelegate.alertViewCancel?(alertView)
        }
    }
    
    public func alertViewShouldEnableFirstOtherButton(alertView: UIAlertView) -> Bool {
        if let block = alertView.block?.shouldEnableFirstOtherButtonBlock {
            return block(alertView: alertView)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIAlertViewBlockKey) as? UIAlertViewDelegate {
            return (originalDelegate.alertViewShouldEnableFirstOtherButton?(alertView))!
        }
        return true
    }
 
}


