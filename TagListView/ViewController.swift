//
//  ViewController.swift
//  TagListView
//
//  Created by 花菜 on 2018/6/6.
//  Copyright © 2018年 Coder.flower. All rights reserved.
//

import UIKit
struct Item: TagViewItem {
    var title: String
}
class ViewController: UIViewController {
    let tagListView = TagListView(frame:CGRect(x: 0, y: 300, width: UIScreen.main.bounds.width, height: 100))
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tagListView.backgroundColor = UIColor.purple
//        tagListView.isAutowrap = false
        view.addSubview(tagListView)
//        tagListView.items = [Item(title: "测试")]
//        tagListView.addTag("测试")
        tagListView.addTags([Item(title: "就是要叫花菜1"),Item(title: "花菜2"),Item(title: "花菜花菜3"),Item(title: "就是要叫花菜4"),Item(title: "花菜5"),Item(title: "就是要叫花菜6"),Item(title: "花菜7"),Item(title: "就是要叫花菜8")])
        tagListView.selectionMode = .none
        tagListView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "更新配置", style: .done, target: self, action: #selector(updateTageViewConfig))
    }

    @objc func updateTageViewConfig() {
        
        tagListView.update { (config) in
            config.textColor = UIColor.white
            config.borderColor = UIColor.blue
            config.selectedBorderColor = UIColor.cyan
            config.selectedBackgroundColor = UIColor.white
            config.selectedTextColor = UIColor.lightGray
            config.backgroundColor = UIColor.black
        }
        
    }

    @IBAction func autoarapAction(_ sender: UISwitch) {
        tagListView.isAutowrap = sender.isOn
    }
    @IBAction func valueChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tagListView.selectionMode = .none
            debugPrint(sender.selectedSegmentIndex )
        case 1:
             debugPrint(sender.selectedSegmentIndex )
            tagListView.selectionMode = .single
        case 2:
            tagListView.selectionMode = .multiple
             debugPrint(sender.selectedSegmentIndex )
        default: break
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// 删除指定 item
        tagListView.removeTag(Item(title: "花菜1"))
    }
    @IBAction func addAction(_ sender: Any) {
        tagListView.addTag(Item(title: "花菜\(arc4random())"))
    }
}

extension ViewController: TagListViewDelegate {
    func tagListView(_ tagListView: TagListView, updateSelected items: [TagViewItem]) {
        debugPrint("选中的标签个数 == \(items.count)")
    }
}
