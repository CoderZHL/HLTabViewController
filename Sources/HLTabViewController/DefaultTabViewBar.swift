//
//  DefaultTabViewBar.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/8/1.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

public protocol DefaultTabViewBarDelegate: class {
    func numberOfTabForTabViewBar(_ tabViewBar: DefaultTabViewBar) -> Int
    func tabViewBar(_ tabViewBar: DefaultTabViewBar, titleForIndex index: Int) -> String?
    func tabViewBar(_ tabViewBar: DefaultTabViewBar, attributedTitleForIndex index: Int) -> NSAttributedString?
    func tabViewBar(_ tabViewBar: DefaultTabViewBar, didSelectIndex index: Int)
}

extension DefaultTabViewBarDelegate {
    public func tabViewBar(_ tabViewBar: DefaultTabViewBar, didSelectIndex index: Int) {}
    
    public func tabViewBar(_ tabViewBar: DefaultTabViewBar, attributedTitleForIndex index: Int) -> NSAttributedString? {
        return nil
    }
}

public class DefaultTabViewBar: TabViewBar {

    public weak var delegate: DefaultTabViewBarDelegate?
    public var normalColor = UIColor(white: 0, alpha: 0.2)
    public var highlightedColor = UIColor(red: 29.0/255.0, green: 154.0/255.0, blue: 1, alpha: 1)
    
    private var widths = [Int: CGFloat]()
    private var buttons = [UIButton]()
    private lazy var _indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.highlightedColor
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var _seperatorView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: self.bounds.height - 0.5, width: self.bounds.width, height: 0.5))
        view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        view.autoresizingMask = UIViewAutoresizing.flexibleTopMargin.union(.flexibleWidth)
        return view
    }()
    private var _curIndex = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = .white
        self.addSubview(self._indicatorView)
        self.addSubview(self._seperatorView)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadTabBar() {
        self.buttons.forEach { (btn) in
            btn.removeFromSuperview()
        }
        let count = self.delegate?.numberOfTabForTabViewBar(self) ?? 1
        let cellWidth = self.bounds.width / CGFloat(count)
        _indicatorView.frame = CGRect(x: 0, y: self.bounds.height - 8, width: cellWidth, height: 2)
        var newBtns = [UIButton]()
        (0 ..< count).indices.forEach { (index) in
            let btn = self.createButton()
            btn.tag = index
            if let title = self.delegate?.tabViewBar(self, attributedTitleForIndex: index) {
                let normalAttString = NSMutableAttributedString(attributedString: title)
                var range = NSMakeRange(0, normalAttString.string.count)
                normalAttString.addAttribute(.foregroundColor, value: self.normalColor, range: range)
                btn.setAttributedTitle(normalAttString, for: .normal)
                
                let highLightedAttString = NSMutableAttributedString(attributedString: title)
                range = NSMakeRange(0, highLightedAttString.string.count)
                highLightedAttString.addAttribute(.foregroundColor, value: self.highlightedColor, range: range)
                btn.setAttributedTitle(highLightedAttString, for: .disabled)
            } else {
                let title = self.delegate?.tabViewBar(self, titleForIndex: index)
                btn.setTitle(title, for: .normal)
                btn.setTitle(title, for: .disabled)
            }
            
            btn.frame = CGRect(x: cellWidth * CGFloat(index), y: 0, width: cellWidth, height: self.bounds.height)
            self.addSubview(btn)
            newBtns.append(btn)
            
            let width = btn.titleLabel?.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.bounds.size.width)).width
            self.widths[index] = width
        }
        self.buttons = newBtns
        if self.buttons.count < 1 { return }
        self.tabDidScrollToIndex(_curIndex)
    }
}

extension DefaultTabViewBar {
    public func tabScrollXPercent(_ percent: CGFloat) {
        var p = max(0, percent)
        p = min(1, p)
        self.updateIndicatorFrame(with: p)
    }
    
    public func tabDidScrollToIndex(_ index: Int) {
        self.buttons.forEach { (button) in
            button.isEnabled = true
        }
        _curIndex = index
        let curButton = self.button(at: _curIndex)
        curButton?.isEnabled = false
        
        let percent = CGFloat(index) / CGFloat(max(1, self.buttons.count - 1))
        self.updateIndicatorFrame(with: percent)
    }
    
    private func updateIndicatorFrame(with percent: CGFloat) {
        guard self.buttons.count > 0 else {
            return
        }
        let index = Int(CGFloat(self.buttons.count - 1) * percent)
        
        let avergeWidth = self.frame.width / CGFloat(self.buttons.count)
        var preWidth = self.widths[index] ?? 0
        if preWidth == 0 { preWidth = avergeWidth }
        
        if index == self.buttons.count - 1 {
            var rect = _indicatorView.frame
            rect.size.width = preWidth
            rect.origin.x = self.bounds.width - avergeWidth / 2 - preWidth / 2
            _indicatorView.frame = rect
            return
        }
        
        var nextWidth = self.widths[index + 1] ?? 0
        if nextWidth == 0 { nextWidth = avergeWidth }
        
        let prePercent = CGFloat(index) / CGFloat(max(1, self.buttons.count - 1))
        let nextPercent = CGFloat(index + 1) / CGFloat(max(1, self.buttons.count - 1))
        
        let width = preWidth + (percent - prePercent) / (nextPercent - prePercent) * (nextWidth - preWidth)
        let centerX = avergeWidth * (0.5 + CGFloat(self.buttons.count - 1) * percent)
        
        var rect = _indicatorView.frame
        rect.origin.x = centerX - width / 2.0
        rect.size.width = width
        _indicatorView.frame = rect
    }
}

extension DefaultTabViewBar {
    private func reloadTab(index: Int) {
        if index >= self.buttons.count { return }
        
        if let btn = self.button(at: index) {
            if let title = self.delegate?.tabViewBar(self, attributedTitleForIndex: index) {
                let normalAttString = NSMutableAttributedString(attributedString: title)
                var range = NSMakeRange(0, normalAttString.string.count)
                normalAttString.addAttribute(.foregroundColor, value: self.normalColor, range: range)
                btn.setAttributedTitle(normalAttString, for: .normal)
                
                let highLightedAttString = NSMutableAttributedString(attributedString: title)
                range = NSMakeRange(0, highLightedAttString.string.count)
                highLightedAttString.addAttribute(.foregroundColor, value: self.highlightedColor, range: range)
                btn.setAttributedTitle(highLightedAttString, for: .disabled)
            } else {
                let title = self.delegate?.tabViewBar(self, titleForIndex: index)
                btn.setTitle(title, for: .normal)
                btn.setTitle(title, for: .disabled)
            }
            
            let width = btn.titleLabel?.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.frame.size.width)).width
            self.widths[index] = width
        }
        
        let percent = CGFloat(_curIndex) / max(1.0, CGFloat(self.buttons.count - 1))
        self.updateIndicatorFrame(with: percent)
    }
}

extension DefaultTabViewBar {
    private func button(at index: Int) -> UIButton? {
        if index < 0 || index >= self.buttons.count { return nil }
        return self.buttons[index]
    }
    
    private func createButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitleColor(self.normalColor, for: .normal)
        btn.setTitleColor(self.highlightedColor, for: .highlighted)
        btn.addTarget(self, action: #selector(self.onBtnClick(sender:)), for: .touchUpInside)
        return btn
    }
    
    @IBAction func onBtnClick(sender: UIButton) {
        self.delegate?.tabViewBar(self, didSelectIndex: sender.tag)
    }
}
