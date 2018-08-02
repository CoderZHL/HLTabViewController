//
//  TabViewControllerPlugin_BottomInset.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/2.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

extension UIScrollView {
    var tabBottomInset: CGFloat {
        get {
            return objc_getAssociatedObject(self, &tabBottomInset_associatedKey) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &tabBottomInset_associatedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

fileprivate var tabBottomInset_associatedKey: String = "tabBottomInset_associatedKey"

public class TabViewControllerPlugin_BottomInset: TabViewControllerPlugin {
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath != "contentSize" { return }
        
    }
    
    func autoFitBottomInset(scrollView: UIScrollView) {
        var barHeight: CGFloat = 0
        if let controller = self.tabViewController {
            barHeight = controller.tabDataSource?.tabHeaderBottomInset(for: controller) ?? 0
        }
        
        var minBottom = scrollView.contentSize.height + barHeight - scrollView.frame.height
        if minBottom >= 0 {
            if scrollView.contentInset.bottom == scrollView.tabBottomInset { return }
            minBottom = scrollView.tabBottomInset
        } else {
            minBottom = max(-minBottom, scrollView.tabBottomInset)
        }
        
        var insets = scrollView.contentInset
        insets.bottom = minBottom
        scrollView.contentInset = insets
    }
}

extension TabViewControllerPlugin_BottomInset {
    public func scrollViewVerticalScroll(contentPercentY: CGFloat) {}
    
    public func scrollViewHorizontalScroll(contentOffsetX: CGFloat) {}
    
    public func scrollViewWillScroll(from index: Int) {}
    
    public func scrollViewDidScroll(to index: Int) {}
    
    public func initPlugin() {}
    
    public func loadPlugin() {
        guard let _ = self.tabViewController?.tabHeaderView else {
            return
        }
        
        self.tabViewController?.viewControllers.enumerated().forEach({ (index, vc) in
            guard let scrollView = vc.tabContentScrollView else { return }
            if scrollView.tabBottomInset == 0 && scrollView.contentInset.bottom > 0 {
                scrollView.tabBottomInset = scrollView.contentInset.bottom
            }
            self.autoFitBottomInset(scrollView: scrollView)
            scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        })
    }
    
    public func removePlugin() {
        self.tabViewController?.viewControllers.enumerated().forEach({ (index, vc) in
            vc.tabContentScrollView?.removeObserver(self, forKeyPath: "contentSize")
        })
    }
    
    
}
