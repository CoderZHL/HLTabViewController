//
//  HeaderTabViewController.swift
//  Example
//
//  Created by 钟浩良 on 2018/8/2.
//  Copyright © 2018年 肇庆市华盈体育文化发展有限公司. All rights reserved.
//

import UIKit
import HLTabViewController

class HeaderTabViewController: TabViewController {
    
    var barHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabDelegate = self
        self.tabDataSource = self
        
        let tabViewBar = DefaultTabViewBar()
        tabViewBar.delegate = self
        let tabViewBarPlugin = TabViewControllerPlugin_TabViewBar(tabViewBar: tabViewBar, delegate: nil)
        self.enablePlugin(tabViewBarPlugin)
        self.enablePlugin(TabViewControllerPlugin_HeaderScroll())
    }

}

extension HeaderTabViewController: TabViewControllerDataSource {
    func tabViewController(_ viewController: TabViewController, viewControllerForIndex index: Int) -> UIViewController {
        let vc = UITableViewController()
        if index == 1 {
            vc.tableView.backgroundColor = .blue
        }
        return vc
    }
    
    func numberOfViewController(for tabViewController: TabViewController) -> Int {
        return 2
    }
    
    func tabHeaderView(for tabViewController: TabViewController) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        return view
    }
    
    func containerInsets(for tabViewController: TabViewController) -> UIEdgeInsets {
        return .zero
    }
    
    func tabHeaderBottomInset(for tabViewController: TabViewController) -> CGFloat {
        return TabViewBarDefaultHeight + (self.navigationController?.navigationBar.frame.maxY ?? 0)
    }
}

extension HeaderTabViewController: TabViewControllerDelegate {
    
}

extension HeaderTabViewController: DefaultTabViewBarDelegate {
    func tabViewBar(_ tabViewBar: DefaultTabViewBar, titleForIndex index: Int) -> String? {
        return index == 0 ? "111" : "222"
    }
    
    func numberOfTabForTabViewBar(_ tabViewBar: DefaultTabViewBar) -> Int {
        return self.numberOfViewController(for: self)
    }
    
    func tabViewBar(_ tabViewBar: DefaultTabViewBar, didSelectIndex index: Int) {
        let anim = labs(index - self.curIndex) > 1 ? false : true
        self.scroll(to: index, animated: anim)
    }
}
