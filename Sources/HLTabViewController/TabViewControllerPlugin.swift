//
//  TabViewControllerPlugin_Base.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/2.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

public protocol TabViewControllerPluginBase: class {
    func scrollViewVerticalScroll(contentPercentY: CGFloat)
    func scrollViewHorizontalScroll(contentOffsetX: CGFloat)
    func scrollViewWillScroll(from index: Int)
    func scrollViewDidScroll(to index: Int)
    func initPlugin()
    func loadPlugin()
    func removePlugin()
//    var tabViewController: TabViewController { get }
}

extension TabViewControllerPluginBase {
    public var tabViewController: TabViewController? {
        get {
            return objc_getAssociatedObject(self, &tabViewController_associatedKey) as? TabViewController
        }
        set {
            objc_setAssociatedObject(self, &tabViewController_associatedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

fileprivate var tabViewController_associatedKey = "tabViewController_associatedKey"

public typealias TabViewControllerPlugin = NSObject & TabViewControllerPluginBase

//class TabViewControllerPlugin_Base: NSObject {
//    var tabViewController: TabViewController!

//    func initPlugin() {}
//
//    func loadPlugin() {}
//
//    func removePlugin() {}
//}
//
//extension TabViewControllerPlugin_Base: TabViewControllerPlugin {
//    func scrollViewVerticalScroll(contentPercentY: CGFloat) {}
//
//    func scrollViewHorizontalScroll(contentOffsetX: CGFloat) {}
//
//    func scrollViewWillScroll(from index: Int) {}
//
//    func scrollViewDidScroll(to index: Int) {}
//
//
//}
