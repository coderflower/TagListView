//
//  TagListView.swift
//  JOU-Swift
//
//  Created by 花菜 on 2018/5/8.
//  Copyright © 2018年 Coder.flower. All rights reserved.
//

import UIKit

public protocol TagViewItem {
    var title: String {get set}
}

public protocol TagListViewDelegate: NSObjectProtocol {
    func tagListView(_ tagListView:TagListView, updateSelected items: [TagViewItem])
}
extension TagListViewDelegate {
    func tagListView(_ tagListView:TagListView, updateSelected items: [TagViewItem]){}
}
/// 标签选择模式
public enum TagSelectionMode {
    case none
    case single
    case multiple
}
public class TagListView: UIView {
    // MARK: - 属性
    /// 是否自动换行
    public var isAutowrap = true {
        didSet {
            updateSubviews()
        }
    }
    /// 选中的 items
    private var selectedItems: [TagViewItem] = []
    /// 所有的 items
    private var items: [TagViewItem] = []
    /// 所有的 tagView
    public var tagViews: [TagView] = []
    /// 标签高度
    private var tagViewHeight: CGFloat = 0
    /// 选择模式,不可选,单选,多选 默认单选
    public var selectionMode: TagSelectionMode = .single {
        didSet {
            tagViews.forEach({ (tagView) in
                tagView.enableSelect = selectionMode != .none
            })
        }
    }
    /// 选中
    public weak var delegate: TagListViewDelegate?
    /// 配置
    private let config = TagListConfig()
    /// 内容视图
    private lazy var containerView = {[weak self] () -> UIScrollView in
        let containerView = UIScrollView()
        containerView.showsVerticalScrollIndicator = false
        containerView.showsHorizontalScrollIndicator = false
        containerView.isScrollEnabled = true
        self?.addSubview(containerView)
        return containerView
    }()
    /// 添加单个 item
    @discardableResult
    open func addTag(_ item: TagViewItem) -> TagView {
        items.append(item)
        return addTagView(createNewTagView(item))
    }
    @discardableResult
    private func addTagView(_ tagView: TagView) -> TagView {
        tagViews.append(tagView)
        containerView.addSubview(tagView)
        updateSubviews()
        return tagView
    }
    /// 数组形式添加 item
    @discardableResult
    open func addTags(_ items: [TagViewItem]) -> [TagView] {
        var tagViews: [TagView] = []
        self.items.append(contentsOf: items)
        for item in items {
            tagViews.append(createNewTagView(item))
        }
        return addTagViews(tagViews)
    }
    
    @discardableResult
    private func addTagViews(_ tagViews: [TagView]) -> [TagView] {
        for tagView in tagViews {
            self.tagViews.append(tagView)
            containerView.addSubview(tagView)
        }
        updateSubviews()
        return tagViews
    }
    /// 插入单个 item
    @discardableResult
    open func insertTag(_ item: TagViewItem, at index: Int) -> TagView {
        items.insert(item, at: index)
        return insertTagView(createNewTagView(item), at: index)
    }
    @discardableResult
    open func insertTagView(_ tagView: TagView, at index: Int) -> TagView {
        tagViews.insert(tagView, at: index)
        containerView.insertSubview(tagView, at: index)
        updateSubviews()
        
        return tagView
    }
    /// 移除某个 item
    open func removeTag(_ item: TagViewItem) {
        // loop the array in reversed order to remove items during loop
        for index in stride(from: (tagViews.count - 1), through: 0, by: -1) {
            let tagView = tagViews[index]
            if tagView.currentTitle == item.title {
                removeTagView(tagView)
            }
        }
    }
    
    private func removeTagView(_ tagView: TagView) {
        tagView.removeFromSuperview()
        if let index = tagViews.index(of: tagView) {
            tagViews.remove(at: index)
        }
        
        updateSubviews()
    }
    
    /// 移除所有的 items
    open func removeAll() {
        for tagView in tagViews {
            tagView.removeFromSuperview()
        }
        items.removeAll()
        tagViews = []
        items = []
        updateSubviews()
    }
    
    /// 根据 item 创建对应的 tagView
    ///
    /// - Parameter item: item
    /// - Returns: tagView
    private func createNewTagView(_ item: TagViewItem) -> TagView {
        let tagView = TagView(title: item.title)
        tagView.item = item
        tagView.addTarget(self, action: #selector(tagViewPressed(_:)), for: .touchUpInside)
        update(tagView)
        return tagView
    }
    /// 更新配置
    func update(_ config: ((TagListConfig) -> ())) {
        config(self.config)
        tagViews.forEach { update($0)}
    }
    private func update(_ tagView: TagView) {
        tagView.paddingX = config.paddingX
        tagView.paddingY = config.paddingY
        tagView.textColor = config.textColor
        tagView.selectedTextColor = config.selectedTextColor
        tagView.textFont = config.textFont
        tagView.selectedBackgroundColor = config.selectedBackgroundColor
        tagView.cornerRadius = config.cornerRadius
        tagView.borderWidth = config.borderWidth
        tagView.borderColor = config.borderColor
        tagView.tagBackgroundColor = config.backgroundColor
        tagView.selectedBorderColor = config.selectedBorderColor
        tagView.highlightedBackgroundColor = config.highlightedBackgroundColor
    }
    
    /// 点击 tagView事件
    ///
    /// - Parameter tagView: TagView
    @objc func tagViewPressed(_ tagView: TagView) {
        switch selectionMode {
        case .none: break
        case .single:
            selectedItems.removeAll()
            tagViews.forEach { (tag) in
                tag.isSelected = false
            }
            tagView.isSelected = true
            selectedItems.removeAll()
            selectedItems.append(tagView.item)
        case .multiple:
            let flag = selectedItems.contains {
                $0.title == tagView.item.title
            }
            if !flag {
                debugPrint("添加到选中--->\(tagView.item.title)")
                tagView.isSelected = true
                selectedItems.append(tagView.item)
            } else {
                debugPrint("从选中去掉--->\(tagView.item.title)")
                tagView.isSelected = false
                if let index = selectedItems.index(where: { $0.title == tagView.item.title }) {
                    selectedItems.remove(at: index)
                }
            }
        }
        /// 告诉代理更新选中的 items
        delegate?.tagListView(self, updateSelected: selectedItems)
    }
    

    override public func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = intrinsicContentSize.height
        self.containerView.frame = bounds
    }
    private(set) var rows = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    override open var intrinsicContentSize: CGSize {
        var size = CGSize.zero
        if isAutowrap {
            var height: CGFloat = 0
            if rows > 0 {
                height = tagViewHeight * CGFloat(rows + 1) +  CGFloat(rows) * config.marginY + config.marginY * 2
            } else {
                height = tagViewHeight + config.marginY * 2
            }
             size = CGSize(width: frame.width, height: height)
        } else {
            let width = tagViews.reduce(config.marginY, { (result, tagView) -> CGFloat in
                /// 获取 tagView 的宽度
                let surroundSize = tagView.intrinsicContentSize
                return result + surroundSize.width + config.marginX
            })
            size = CGSize(width: width, height: tagViewHeight + config.marginY * 2)
        }
        containerView.contentSize = CGSize(width: size.width, height: 0)
        return size
    }
    func updateSubviews() {
        /// 移除原有的
        tagViews.forEach { $0.removeFromSuperview()}
        items.removeAll()
        rows = 0
        var originX: CGFloat = config.marginX
        var originY: CGFloat = config.marginY
        for tagView in tagViews {
            tagView.enableSelect = (selectionMode != .none)
            // 获取尺寸
            tagView.frame.size = tagView.intrinsicContentSize
            tagViewHeight = tagView.frame.height
            
            if isAutowrap {
                let offsetX = originX + tagView.frame.width + config.marginX
                if offsetX > frame.width {
                    originX = config.marginX
                    // 加一个间距
                    originY =  originY + tagView.frame.height + config.marginY
                    rows = rows + 1
                }
                tagView.frame.origin.y = originY
                tagView.frame.origin.x = originX
            } else {
                tagView.frame.origin.y = config.marginY
                tagView.frame.origin.x = originX
            }
            originX = originX + tagView.frame.width + config.marginX
            containerView.addSubview(tagView)
        }
        /// 添加需要重新布局标记
        self.setNeedsLayout()
        /// 重新布局
        self.layoutIfNeeded()
        
    }
}


class TagListConfig {
    /// 文本颜色
    var textColor: UIColor = UIColor.black
    /// 选中文本颜色
    var selectedTextColor: UIColor = UIColor.white
    /// 文本字体
    var textFont = UIFont.systemFont(ofSize: 12)
    /// 圆角
    var cornerRadius: CGFloat = 3
    /// 边框颜色
    var borderColor: UIColor = UIColor.lightGray
    /// 选中的边框颜色
    var selectedBorderColor: UIColor = UIColor.lightGray
    /// 边框宽度
    var borderWidth: CGFloat = 1
    /// 背景颜色
    var backgroundColor: UIColor = UIColor.lightGray
    /// 选中背景颜色
    var selectedBackgroundColor: UIColor = UIColor.red
    var highlightedBackgroundColor: UIColor = UIColor.red
    /// 标签x边距
    var paddingX: CGFloat = 3
    /// 标签 y 边距
    var paddingY: CGFloat = 3
    /// 列间距
    var marginY: CGFloat = 5
    /// 标签行间距
    var marginX: CGFloat = 5
}
