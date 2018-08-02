//
//  PageTabViewController.swift
//  Example
//
//  Created by 钟浩良 on 2018/8/2.
//  Copyright © 2018年 肇庆市华盈体育文化发展有限公司. All rights reserved.
//

import UIKit
import HLTabViewController

class PageTabViewController: TabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabDataSource = self
    }

}

extension PageTabViewController: TabViewControllerDataSource {
    func numberOfViewController(for tabViewController: TabViewController) -> Int {
        return 2
    }
    
    func tabViewController(_ viewController: TabViewController, viewControllerForIndex index: Int) -> UIViewController {
        let vc = UITableViewController()
        if index == 1 {
            vc.tableView.backgroundColor = .blue
        }
        return vc
    }
    func containerInsets(for tabViewController: TabViewController) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.navigationController?.navigationBar.frame.maxY ?? 0, left: 0, bottom: 0, right: 0)
    }
    
    
}
