//
//  BarTabViewController.swift
//  Example
//
//  Created by 钟浩良 on 2018/8/2.
//  Copyright © 2018年 肇庆市华盈体育文化发展有限公司. All rights reserved.
//

import UIKit
import HLTabViewController

class BarTabViewController: TabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabDataSource = self
        self.tabDelegate = self
        
        let tabViewBar = DefaultTabViewBar()
        tabViewBar.delegate = self
        let tabViewBarPlugin = TabViewControllerPlugin_TabViewBar(tabViewBar: tabViewBar, delegate: nil)
        self.enablePlugin(tabViewBarPlugin)
    }

}

extension BarTabViewController: TabViewControllerDataSource {
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
    
    func containerInsets(for tabViewController: TabViewController) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.navigationController?.navigationBar.frame.maxY ?? 0, left: 0, bottom: 0, right: 0)
    }
    
    
}

extension BarTabViewController: TabViewControllerDelegate {
    
}

extension BarTabViewController: DefaultTabViewBarDelegate {
    func numberOfTabForTabViewBar(_ tabViewBar: DefaultTabViewBar) -> Int {
        return self.numberOfViewController(for: self)
    }
    
    func tabViewBar(_ tabViewBar: DefaultTabViewBar, titleForIndex index: Int) -> String? {
        return index == 0 ? "111" : "222"
    }
    
    func tabViewBar(_ tabViewBar: DefaultTabViewBar, didSelectIndex index: Int) {
        let anim = labs(index - self.curIndex) > 1 ? false : true
        self.scroll(to: index, animated: anim)
    }
}
