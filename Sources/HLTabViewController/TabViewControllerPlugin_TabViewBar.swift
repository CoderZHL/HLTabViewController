//
//  TabViewControllerPlugin_TabViewBar.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/2.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

public protocol TabViewBarPluginDelegate: class {
    func tabViewController(_ viewController: TabViewController, didLoadTabViewBar tabViewBar: TabViewBar)
}

extension TabViewBarPluginDelegate {
    func tabViewController(_ viewController: TabViewController, didLoadTabViewBar tabViewBar: TabViewBar) {}
}

public class TabViewControllerPlugin_TabViewBar: TabViewControllerPlugin {
    private var _loadFlag = false
    private var _tabCount = 0
    private var _maxIndicatorX: CGFloat = 0
    
    private weak var delegate: TabViewBarPluginDelegate?
    private var tabViewBar: TabViewBar!
    
    public init(tabViewBar: TabViewBar, delegate: TabViewBarPluginDelegate?) {
        super.init()
        self.tabViewBar = tabViewBar
        self.delegate = delegate
    }
    
    func layoutTabViewBar() {
        if _loadFlag { return }
        _loadFlag = true
        let tabBarHeight = self.tabViewBar.frame.height
        if self.tabViewController?.tabHeaderView == nil {
            self.tabViewBar.frame = CGRect(x: 0, y: 0, width: self.tabViewController?.scrollView.frame.width ?? 0, height: tabBarHeight)
            self.tabViewController?.tabHeaderView = self.tabViewBar
            return
        }
        
        let tabBarFrameMinY = (self.tabViewController?.tabHeaderView?.frame.height ?? 0) - tabBarHeight
        self.tabViewBar.frame = CGRect(x: 0, y: tabBarFrameMinY, width: self.tabViewController?.scrollView.frame.width ?? 0, height: tabBarHeight)
        self.tabViewBar.autoresizingMask = .flexibleTopMargin
        self.tabViewController?.tabHeaderView?.addSubview(self.tabViewBar)
    }
}

extension TabViewControllerPlugin_TabViewBar {
    public func scrollViewVerticalScroll(contentPercentY: CGFloat) {}
    
    public func scrollViewHorizontalScroll(contentOffsetX: CGFloat) {
        self.tabViewBar.tabScrollXOffset(contentOffsetX)
        let percent = contentOffsetX / _maxIndicatorX
        self.tabViewBar.tabScrollXPercent(percent)
    }
    
    public func scrollViewWillScroll(from index: Int) {}
    
    public func scrollViewDidScroll(to index: Int) {
        self.tabViewBar.tabDidScrollToIndex(index)
    }
    
    public func initPlugin() {
        if self.tabViewBar.frame.height == 0 {
            self.tabViewBar.frame = CGRect(x: 0, y: 0, width: 0, height: TabViewBarDefaultHeight)
        }
    }
    
    public func loadPlugin() {
        if let controller = self.tabViewController {
            _tabCount = controller.tabDataSource?.numberOfViewController(for: controller) ?? 0
        } else {
            _tabCount = 0
        }
        _maxIndicatorX = (self.tabViewController?.scrollView.frame.width ?? 0) * CGFloat(_tabCount - 1)
        self.layoutTabViewBar()
        self.tabViewBar.reloadTabBar()
        if let controller = self.tabViewController {
            self.delegate?.tabViewController(controller, didLoadTabViewBar: self.tabViewBar)
        }
    }
    
    public func removePlugin() {
        self.tabViewBar.removeFromSuperview()
        _loadFlag = false
    }
    
    
}
