//
//  UIActionSheet+Block.swift
//  UIAlertViewBlocks
//
//  Created by Drew on 16/8/19.
//  Copyright © 2016年 Drew. All rights reserved.
//

/**
    UIActionSheet的类扩展，使用block来代替实现代理方法完成回调
 */

import UIKit

extension UIActionSheet {
    private struct AssociatedKey {
        static var UIActionSheetOriginalDelegateKey  = "UIActionSheetOriginalDelegateKey"
        static var UIActionSheetBlockKey = "UIActionSheetTapBlockKey"
    }
    
    typealias UIActionSheetBlock = (actionSheet: UIActionSheet)->Void
    typealias UIActionSheetCompletionBlock = (actionSheet: UIActionSheet, buttonIndex : Int)->Void
    
    // 定义block类，每个Block对应一个代理方法
    class Block {
        var tapBlock : UIActionSheetCompletionBlock?
        var willPresentBlock : UIActionSheetBlock?
        var didPresentBlock : UIActionSheetBlock?
        var willDismissBlock : UIActionSheetCompletionBlock?
        var didDismissBlock : UIActionSheetCompletionBlock?
        var cancelBlock : UIActionSheetBlock?
    }
    
    // 利用runtime为UIActionSheet添加block属性
    private var block : Block? {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKey.UIActionSheetBlockKey) {
                return value as? Block
            }
            return nil
        }
        set (newValue) {
            self.checkActionSheetDelegate()
            if let _ = objc_getAssociatedObject(self, &AssociatedKey.UIActionSheetBlockKey) {
                objc_setAssociatedObject(self, &AssociatedKey.UIActionSheetBlockKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            objc_setAssociatedObject(self, &AssociatedKey.UIActionSheetBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 构造方法
    convenience init(title : String,
         cancelButtonTitle : String,
    destructiveButtonTitle : String,
         otherButtonTitles : [String],
                  tapBlock : UIActionSheetCompletionBlock?) {
        self.init(title: title, delegate: nil, cancelButtonTitle: cancelButtonTitle, destructiveButtonTitle: destructiveButtonTitle)
        
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
  
    // 检查是否有设置代理
    func checkActionSheetDelegate() {
        
        if self.delegate == nil {
            self.delegate = self
        } else if !self.delegate!.isEqual(self) {
            objc_setAssociatedObject(self, &AssociatedKey.UIActionSheetOriginalDelegateKey, self.delegate, .OBJC_ASSOCIATION_ASSIGN)
            self.delegate = self
        }
    }
    
    // 为UIActionSheet添加各代理方法对应的block
    func tapBlock(tapBlock: UIActionSheetCompletionBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.tapBlock = tapBlock
        self.block = blockMgr
    }
    func willDismissBlock(willDismissBlock: UIActionSheetCompletionBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.willDismissBlock = willDismissBlock
        self.block = blockMgr
    }
    func didDismissBlock(didDismissBlock: UIActionSheetCompletionBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.didDismissBlock = didDismissBlock
        self.block = blockMgr
    }
    func willPresentBlock(willPresentBlock: UIActionSheetBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.willPresentBlock = willPresentBlock
        self.block = blockMgr
    }
    func didPresentBlock(didPresentBlock: UIActionSheetBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.didPresentBlock = didPresentBlock
        self.block = blockMgr
    }
    func cancelBlock(cancelBlock: UIActionSheetBlock) {
        let blockMgr = self.block ?? Block()
        blockMgr.cancelBlock = cancelBlock
        self.block = blockMgr
    }
}

extension UIActionSheet: UIActionSheetDelegate{
    
    public func actionSheetCancel(actionSheet: UIActionSheet) {
        if let block = actionSheet.block?.cancelBlock {
            block(actionSheet: actionSheet)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIActionSheetBlockKey) as? UIActionSheetDelegate {
            originalDelegate.actionSheetCancel?(actionSheet)
        }
    }
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let completion = actionSheet.block?.tapBlock {
            completion(actionSheet: actionSheet, buttonIndex: buttonIndex)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIActionSheetOriginalDelegateKey) as? UIActionSheetDelegate {
            originalDelegate.actionSheet?(actionSheet, clickedButtonAtIndex: buttonIndex)
        }
    }
    
    public func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if let completion = actionSheet.block?.willDismissBlock {
            completion(actionSheet: actionSheet, buttonIndex: buttonIndex)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIActionSheetOriginalDelegateKey) as? UIActionSheetDelegate {
            originalDelegate.actionSheet?(actionSheet, willDismissWithButtonIndex: buttonIndex)
        }
    }
    
    public func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if let completion = actionSheet.block?.didDismissBlock {
            completion(actionSheet: actionSheet, buttonIndex: buttonIndex)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIActionSheetOriginalDelegateKey) as? UIActionSheetDelegate {
            originalDelegate.actionSheet?(actionSheet, didDismissWithButtonIndex: buttonIndex)
        }
    }
    
    public func willPresentActionSheet(actionSheet: UIActionSheet) {
        if let block = actionSheet.block?.willPresentBlock {
            block(actionSheet: actionSheet)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIActionSheetBlockKey) as? UIActionSheetDelegate {
            originalDelegate.willPresentActionSheet?(actionSheet)
        }
    }
    
    public func didPresentActionSheet(actionSheet: UIActionSheet) {
        if let block = actionSheet.block?.didPresentBlock {
            block(actionSheet: actionSheet)
        }
        if let originalDelegate = objc_getAssociatedObject(self, &AssociatedKey.UIActionSheetBlockKey) as? UIActionSheetDelegate {
            originalDelegate.didPresentActionSheet?(actionSheet)
        }
    }
}
