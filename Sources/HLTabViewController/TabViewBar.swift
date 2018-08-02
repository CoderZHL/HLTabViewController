//
//  TabViewBar.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/1.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

public protocol TabViewBarType {
    func reloadTabBar()
    func tabScrollXPercent(_ percent: CGFloat)
    func tabScrollXOffset(_ offsetX: CGFloat)
    func tabDidScrollToIndex(_ index: Int)
}
extension TabViewBarType {
    public func tabScrollXPercent(_ percent: CGFloat) {}
    public func tabScrollXOffset(_ offsetX: CGFloat) {}
    public func tabDidScrollToIndex(_ index: Int) {}
}

public typealias TabViewBar = UIView & TabViewBarType

public let TabViewBarDefaultHeight: CGFloat = 44.0
