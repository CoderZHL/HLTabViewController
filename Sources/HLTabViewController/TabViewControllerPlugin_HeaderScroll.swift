//
//  TabViewControllerPlugin_HeaderScroll.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/2.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

public class TabViewControllerPlugin_HeaderScroll: TabViewControllerPlugin {
    private var index = 0
    
    func addPanGesture(for index: Int) {
        if let vc = self.tabViewController?.viewController(for: index), let scrollView = vc.tabContentScrollView {
            self.tabViewController?.view.addGestureRecognizer(scrollView.panGestureRecognizer)
        }
    }
    
    func removePanGesture(for index: Int) {
        if let vc = self.tabViewController?.viewController(for: index), let scrollView = vc.tabContentScrollView {
            self.tabViewController?.view.removeGestureRecognizer(scrollView.panGestureRecognizer)
        }
    }
}

extension TabViewControllerPlugin_HeaderScroll {
    public func scrollViewVerticalScroll(contentPercentY: CGFloat) {}
    
    public func scrollViewHorizontalScroll(contentOffsetX: CGFloat) {}
    
    public func scrollViewWillScroll(from index: Int) {
        self.index = index
    }
    
    public func scrollViewDidScroll(to index: Int) {
        if self.index == index { return }
        self.removePanGesture(for: self.index)
        self.addPanGesture(for: index)
        self.index = index
    }
    
    public func initPlugin() {}
    
    public func loadPlugin() {
        guard let vc = self.tabViewController else { return }
        self.addPanGesture(for: vc.curIndex)
        self.index = vc.curIndex
    }
    
    public func removePlugin() {
        guard let vc = self.tabViewController else { return }
        self.removePanGesture(for: vc.curIndex)
    }
}
