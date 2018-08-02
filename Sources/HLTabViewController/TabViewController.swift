//
//  TabViewController.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/1.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

public protocol TabViewControllerDelegate: class {
    func tabViewController(_ viewController: TabViewController, scrollViewVerticalScroll contentPercentY: CGFloat)
    func tabViewController(_ viewController: TabViewController, scrollViewHorizontalScroll contentOffsetX: CGFloat)
    func tabViewController(_ viewController: TabViewController, scrollViewWillScrollFromIndex index: Int)
    func tabViewController(_ viewController: TabViewController, scrollViewDidScrollToIndex index: Int)
}
extension TabViewControllerDelegate {
    public func tabViewController(_ viewController: TabViewController, scrollViewVerticalScroll contentPercentY: CGFloat) {}
    public func tabViewController(_ viewController: TabViewController, scrollViewHorizontalScroll contentOffsetX: CGFloat) {}
    public func tabViewController(_ viewController: TabViewController, scrollViewWillScrollFromIndex index: Int) {}
    public func tabViewController(_ viewController: TabViewController, scrollViewDidScrollToIndex index: Int) {}
}

public protocol TabViewControllerDataSource: class {
    func numberOfViewController(for tabViewController: TabViewController) -> Int
    func tabViewController(_ viewController: TabViewController, viewControllerForIndex index: Int) -> UIViewController
    func tabHeaderView(for tabViewController: TabViewController) -> UIView?
    func tabHeaderBottomInset(for tabViewController: TabViewController) -> CGFloat
    func containerInsets(for tabViewController: TabViewController) -> UIEdgeInsets
}
extension TabViewControllerDataSource {
    public func tabHeaderView(for tabViewController: TabViewController) -> UIView? {
        return nil
    }
    public func tabHeaderBottomInset(for tabViewController: TabViewController) -> CGFloat {
        return 0
    }
    public func containerInsets(for tabViewController: TabViewController) -> UIEdgeInsets {
        return .zero
    }
}

open class TabViewController: UIViewController {
    
    public weak var tabDataSource: TabViewControllerDataSource?
    public weak var tabDelegate: TabViewControllerDelegate?
    public var curIndex = 0
    public var tabHeaderView: UIView?
    public var plugins = [TabViewControllerPlugin]()
    var headerZoomIn = false
    
    private(set) var scrollView: UIScrollView!
    private var containerView: UIView!
    private(set) var viewControllers = [UIViewController]()
    private var showIndexAfterAppear = 0
    private var _headParameter: HeadParameter!
    private var _loadParameter: LoadParameter = LoadParameter(tabViewLoadFlag: false, pluginsLoadFlag: false)
    private var _contentOffsetY: CGFloat = 0
    private var _headViewScrollEnable = false
    private var _viewDidAppearIsCalledBefore = false
    
    deinit {
        self.removeKVOObserver()
        self.plugins.forEach { (plugin) in
            plugin.removePlugin()
        }
        self.viewControllers.forEach { (vc) in
            vc.tabViewController = nil
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.curIndex != Int(self.scrollView.contentOffset.x / self.scrollView.frame.width) {
            self.scrollViewDidEndDecelerating(self.scrollView)
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.loadContainerView()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadContentView()
        self.layoutSubViewWhenScrollViewFrameChange()
        if self.showIndexAfterAppear > 0 {
            self.scroll(to: self.showIndexAfterAppear, animated: false)
            self.showIndexAfterAppear = 0
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !_viewDidAppearIsCalledBefore {
            _viewDidAppearIsCalledBefore = true
            self.viewDidScroll(to: self.curIndex)
            if _headViewScrollEnable {
                self.tabDelegateScrollViewVerticalScroll(percent: 0)
            }
        }
    }
    
    func reloadData() {
        self.plugins.forEach { (plugin) in
            plugin.removePlugin()
        }
        self.tabHeaderView?.removeFromSuperview()
        self.tabHeaderView = nil
        
        self.removeKVOObserver()
        self.viewControllers.forEach { (vc) in
            vc.tabViewController = nil
            vc.view.removeFromSuperview()
        }
        self.viewControllers = []
        self.scrollView.contentOffset = .zero
        self.curIndex = 0
        _contentOffsetY = 0
        _headViewScrollEnable = false
        
        _loadParameter.pluginsLoadFlag = false
        _loadParameter.tabViewLoadFlag = false
        self.loadContentView()
    }
}

extension TabViewController {
    func loadContainerView() {
        self.view.backgroundColor = .white
        self.automaticallyAdjustsScrollViewInsets = false
        self.headerZoomIn = true
        
        self.containerView = UIView(frame: self.view.bounds)
        self.containerView.backgroundColor = .clear
        self.containerView.clipsToBounds = true
        self.containerView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleWidth)
        self.view.addSubview(self.containerView)
        
        self.scrollView = UIScrollView(frame: self.containerView.bounds)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.isDirectionalLockEnabled = true
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = false
        self.scrollView.delegate = self
        self.scrollView.scrollsToTop = false
        self.scrollView.delaysContentTouches = false
        self.scrollView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        self.containerView.addSubview(self.scrollView)
    }
    
    // 准备和布局所有子视图
    func loadContentView() {
        if _loadParameter.tabViewLoadFlag { return }
        _loadParameter.tabViewLoadFlag = true
        self.layoutContainerView()
        self.loadViewControllersDataSource()
        self.loadHeadViewDataSource()
        self.loadPlugins()
        self.loadGeneralParam()
        self.loadControllerView()
        self.layoutHeaderView()
        self.layoutControllerView()
        self.curScrollViewScrollToTop(isEnable: true)
        if _headViewScrollEnable {
            self.tabDelegateScrollViewVerticalScroll(percent: 0)
        }
    }
    // 根据dataSource调整containerView的frame
    func layoutContainerView() {
        guard let insets = self.tabDataSource?.containerInsets(for: self) else {
            return
        }
        self.containerView.frame = UIEdgeInsetsInsetRect(self.view.bounds, insets)
    }
    // 根据dataSource创建所有翻页的viewController
    func loadViewControllersDataSource() {
        var viewControllers = [UIViewController]()
        let count = self.tabDataSource?.numberOfViewController(for: self) ?? 0
        for i in 0 ..< count {
            if let vc = self.tabDataSource?.tabViewController(self, viewControllerForIndex: i) {
                viewControllers.append(vc)
            }
        }
        self.viewControllers = viewControllers
    }
    // 根据dataSource创建头部视图
    func loadHeadViewDataSource() {
        if let headerView = self.tabDataSource?.tabHeaderView(for: self) {
            headerView.clipsToBounds = true
            self.tabHeaderView = headerView
            self._headViewScrollEnable = true
        }
    }
    // 确定headParameter
    func loadGeneralParam() {
        var bottomInset: CGFloat = 0
        var headHeight: CGFloat = 0
        if let inset = self.tabDataSource?.tabHeaderBottomInset(for: self) {
            bottomInset = inset
        }
        if let header = self.tabHeaderView {
            headHeight = header.frame.height
        } else {
            headHeight = bottomInset
        }
        self._headParameter = HeadParameter(headHeight: headHeight, bottomInset: bottomInset, minHeadFrameOriginY: -headHeight + bottomInset)
    }
    // 配置所有翻页视图
    func loadControllerView() {
        let count = CGFloat(self.viewControllers.count)
        let width = self.scrollView.bounds.width
        let height = self.scrollView.bounds.height
        self.scrollView.contentSize = CGSize(width: width * count, height: height)
        self.viewControllers.enumerated().forEach { (index, vc) in
            vc.view.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height)
            vc.tabViewController = self
            
            if let scrollView = vc.tabContentScrollView {
                var inset = scrollView.contentInset
                inset.top += _headParameter.headHeight
                scrollView.contentInset = inset
                scrollView.scrollIndicatorInsets = inset
                scrollView.contentOffset = CGPoint(x: 0, y: -inset.top)
                scrollView.scrollsToTop = false
                if #available(iOS 11.0, *) {
                    scrollView.contentInsetAdjustmentBehavior = .never
                }
                scrollView.addObserver(self, forKeyPath: "contentOffset", options: .old, context: nil)
            }
        }
    }
    // 布局头部视图
    func layoutHeaderView() {
        guard let headerView = self.tabHeaderView else {
            return
        }
        headerView.clipsToBounds = true
        headerView.frame = CGRect(x: 0, y: 0, width: self.containerView.bounds.width, height: _headParameter.headHeight)
        self.containerView.insertSubview(headerView, aboveSubview: self.scrollView)
    }
    // 更新当前显示的子控制器
    func layoutControllerView() {
        let width = self.scrollView.bounds.width
        self.viewControllers.enumerated().forEach { (index, vc) in
            let pageOffsetForChild = CGFloat(index) * width
            if fabs(self.scrollView.contentOffset.x - pageOffsetForChild) < width {
                if vc.parent == nil {
                    vc.willMove(toParentViewController: self)
                    self.addChildViewController(vc)
                    vc.beginAppearanceTransition(true, animated: true)
                    self.scrollView.addSubview(vc.view)
                    vc.didMove(toParentViewController: self)
                    if _viewDidAppearIsCalledBefore {
                        vc.endAppearanceTransition()
                    }
                    self.autoFitLayoutControllerView(viewController: vc)
                }
            } else {
                if let _ = vc.parent {
                    vc.willMove(toParentViewController: nil)
                    vc.beginAppearanceTransition(false, animated: true)
                    vc.view.removeFromSuperview()
                    vc.removeFromParentViewController()
                    vc.endAppearanceTransition()
                }
            }
        }
    }
    // 调整子控制scrollView的contentOffset.y
    func autoFitLayoutControllerView(viewController: UIViewController) {
        if let scrollView = viewController.tabContentScrollView {
            let maxY = -min(self.tabHeaderView?.frame.maxY ?? 0, _headParameter.headHeight)
            if scrollView.contentOffset.y < maxY {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: maxY)
            }
        }
    }
    func curScrollViewScrollToTop(isEnable: Bool) {
        if let vc = self.viewController(for: self.curIndex) {
            vc.tabContentScrollView?.scrollsToTop = isEnable
        }
    }
    // 通知当前的scrollView垂直滚动值
    func tabDelegateScrollViewVerticalScroll(percent: CGFloat) {
        self.tabDelegate?.tabViewController(self, scrollViewVerticalScroll: percent)
        self.plugins.forEach { (plugin) in
            plugin.scrollViewVerticalScroll(contentPercentY: percent)
        }
    }
}

extension TabViewController {
    // 当scrollView的Frame变化时，调整子控制器视图的frame
    func layoutSubViewWhenScrollViewFrameChange() {
        if self.scrollView.frame.height == self.scrollView.contentSize.height { return }
        let count = self.viewControllers.count
        let widht = self.scrollView.bounds.width
        let height = self.scrollView.bounds.height
        self.scrollView.contentSize = CGSize(width: widht * CGFloat(count), height: height)
        self.viewControllers.enumerated().forEach { (index, vc) in
            vc.view.frame = CGRect(x: widht * CGFloat(index), y: 0, width: widht, height: height)
        }
    }
}

extension TabViewController {
    public func scroll(to index: Int, animated: Bool) {
        if !_loadParameter.tabViewLoadFlag {
            self.showIndexAfterAppear = index
            return
        }
        if index < 0 || index >= self.viewControllers.count || index == self.curIndex { return }
        self.curScrollViewScrollToTop(isEnable: false)
        self.viewControllersAutoFitToScrollView(to: index)
        self.tabDelegate?.tabViewController(self, scrollViewWillScrollFromIndex: self.curIndex)
        self.plugins.forEach { (plugin) in
            plugin.scrollViewWillScroll(from: self.curIndex)
        }
        self.scrollView.setContentOffset(CGPoint(x: CGFloat(index) * self.scrollView.bounds.width, y: 0), animated: animated)
        if !animated {
            self.scrollViewDidEndDecelerating(self.scrollView)
        }
    }
    func viewControllersAutoFitToScrollView(to index: Int) {
        if index < 0 || index >= self.viewControllers.count { return }
        var minIndex = 0
        var maxIndex = self.viewControllers.count
        if index < self.curIndex {
            minIndex = index
            maxIndex = self.curIndex - 1
        } else {
            minIndex = self.curIndex + 1
            maxIndex = index
        }
        for i in minIndex ... maxIndex {
            let vc = self.viewControllers[i]
            self.autoFit(to: vc)
        }
    }
    func autoFit(to viewController: UIViewController) {
        guard let scrollView = viewController.tabContentScrollView else {
            return
        }
        let maxY = -min(self.tabHeaderView?.frame.maxY ?? 0, _headParameter.headHeight)
        if scrollView.contentOffset.y < maxY {
            if let headerView = self.tabHeaderView {
                let tempRect = headerView.frame
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: maxY)
                headerView.frame = tempRect
            }
        }
        let minY = scrollView.contentSize.height - scrollView.frame.height
        if scrollView.contentOffset.y > minY {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -(self.tabHeaderView?.frame.maxY ?? 0))
        }
    }
}

extension TabViewController {
    func viewController(for index: Int) -> UIViewController? {
        if index < 0 || index >= self.viewControllers.count {
            return nil
        }
        return self.viewControllers[index]
    }
}

extension TabViewController {
    func loadPlugins() {
        self.plugins.forEach { (plugin) in
            plugin.loadPlugin()
        }
        _loadParameter.pluginsLoadFlag = true
    }
    public func enablePlugin(_ plugin: TabViewControllerPlugin) {
        var pluginsForRemove = [TabViewControllerPlugin]()
        var newPlugins = [TabViewControllerPlugin]()
        self.plugins.forEach { (_plugin) in
            if _plugin.isMember(of: type(of: plugin)) {
                pluginsForRemove.append(_plugin)
            } else {
                newPlugins.append(_plugin)
            }
        }
        plugin.tabViewController = self
        plugin.initPlugin()
        newPlugins.append(plugin)
        self.plugins = newPlugins
        pluginsForRemove.forEach { (_plugin) in
            _plugin.removePlugin()
        }
        
        if _loadParameter.pluginsLoadFlag {
            plugin.loadPlugin()
        }
    }
    func removePlugin(_ plugin: TabViewControllerPlugin) {
        plugin.removePlugin()
        plugin.tabViewController = nil
        self.plugins.removeAll()
    }
}

extension TabViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.curScrollViewScrollToTop(isEnable: false)
        self.viewControllersAutoFitToScrollView(to: self.curIndex - 1)
        self.viewControllersAutoFitToScrollView(to: self.curIndex + 1)
        self.tabDelegate?.tabViewController(self, scrollViewWillScrollFromIndex: self.curIndex)
        self.plugins.forEach { (plugin) in
            plugin.scrollViewWillScroll(from: self.curIndex)
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.layoutControllerView()
        self.tabDelegate?.tabViewController(self, scrollViewHorizontalScroll: scrollView.contentOffset.x)
        self.plugins.forEach { (plugin) in
            plugin.scrollViewHorizontalScroll(contentOffsetX: scrollView.contentOffset.x)
        }
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollViewDidEndDecelerating(scrollView)
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.curIndex = Int(CGFloat(scrollView.contentOffset.x) / scrollView.frame.width)
        let vc = self.viewController(for: self.curIndex)
        guard let curScrollView = vc?.tabContentScrollView else { return }
        let insets = curScrollView.contentInset
        let maxY = insets.bottom + curScrollView.contentSize.height - curScrollView.bounds.size.height
        if curScrollView.contentOffset.y > maxY {
            curScrollView.setContentOffset(CGPoint(x: 0, y: -insets.top), animated: true)
        }
        _contentOffsetY = curScrollView.contentOffset.y
        if #available(iOS 11, *) {
            if _contentOffsetY < 0 && _contentOffsetY < -(self.tabHeaderView?.frame.maxY ?? 0) {
                self.observeValue(forKeyPath: "contentOffset", of: curScrollView, change: nil, context: nil)
            }
        }
        self.curScrollViewScrollToTop(isEnable: true)
        self.viewDidScroll(to: self.curIndex)
    }
}

extension TabViewController {
    func viewDidScroll(to index: Int) {
        self.tabDelegate?.tabViewController(self, scrollViewDidScrollToIndex: index)
        self.plugins.forEach { (plugin) in
            plugin.scrollViewDidScroll(to: index)
        }
    }
}

extension TabViewController {
    func removeKVOObserver() {
        self.viewControllers.forEach { (vc) in
            vc.tabContentScrollView?.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard _headViewScrollEnable else {
            return
        }
        let viewController = self.viewController(for: self.curIndex)
        guard let scrollView = viewController?.tabContentScrollView, let obj = object as? UIScrollView, scrollView === obj else {
            return
        }
        let disY = _contentOffsetY - scrollView.contentOffset.y
        _contentOffsetY = scrollView.contentOffset.y
        if disY > 0 && _contentOffsetY > -(self.tabHeaderView?.frame.maxY ?? 0) { return }
        var headRect = self.tabHeaderView?.frame ?? .zero
        if _contentOffsetY > -_headParameter.headHeight {
            headRect.size.height = _headParameter.headHeight
            headRect.origin.y += disY
            headRect.origin.y = min(headRect.minY, 0)
            headRect.origin.y = max(headRect.minY, _headParameter.minHeadFrameOriginY)
            headRect.origin.y = max(headRect.minY, -_contentOffsetY - _headParameter.headHeight)
        } else {
            headRect.origin.y = 0
            headRect.size.height = self.headerZoomIn ? -scrollView.contentOffset.y : _headParameter.headHeight
        }
        self.tabHeaderView?.frame = headRect
        
        var percent: CGFloat = 1
        if _headParameter.minHeadFrameOriginY != 0 {
            percent = max(0, headRect.minY / _headParameter.minHeadFrameOriginY)
            percent = min(1, percent)
        }
        self.tabDelegateScrollViewVerticalScroll(percent: percent)
    }
}

extension TabViewController {
    struct LoadParameter {
        var tabViewLoadFlag = false
        var pluginsLoadFlag = false
    }
    
    struct HeadParameter {
        let headHeight: CGFloat
        let bottomInset: CGFloat
        let minHeadFrameOriginY: CGFloat
    }
}
