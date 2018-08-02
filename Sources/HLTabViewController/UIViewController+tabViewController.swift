//
//  UIViewController+tabViewController.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/2.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

extension UIViewController {
    var tabViewController: TabViewController? {
        get {
            return objc_getAssociatedObject(self, &tabViewController_associatedKey) as? TabViewController
        }
        set {
            objc_setAssociatedObject(self, &tabViewController_associatedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var tabContentScrollView: UIScrollView? {
        get {
            if let scrollView = objc_getAssociatedObject(self, &tabContentScrollView_associatedKey) as? UIScrollView {
                return scrollView
            }
            if self.view.isKind(of: UIScrollView.self) {
                self.tabContentScrollView = self.view as? UIScrollView
            } else {
                for subView in self.view.subviews {
                    if subView.isKind(of: UIScrollView.self) && __CGSizeEqualToSize(subView.frame.size, self.view.frame.size) {
                        self.tabContentScrollView = subView as? UIScrollView
                        break
                    }
                }
            }
            return objc_getAssociatedObject(self, &tabContentScrollView_associatedKey) as? UIScrollView
        }
        set {
            objc_setAssociatedObject(self, &tabContentScrollView_associatedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
}


fileprivate var tabViewController_associatedKey = "tabViewController_associatedKey"
fileprivate var tabContentScrollView_associatedKey = "tabContentScrollView_associatedKey"
