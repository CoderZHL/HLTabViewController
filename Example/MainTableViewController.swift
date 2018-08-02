//
//  MainTableViewController.swift
//  HLMiscExample
//
//  Created by 钟浩良 on 2018/7/11.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

fileprivate struct RowModel {
    let title: String
    let handler: () -> Void
}

class MainTableViewController: UITableViewController {
    
    private lazy var rowModels: [RowModel] = {
        var models: [RowModel] = []
        models.append(RowModel(title: "PageTabViewController", handler: { [unowned self] in
            let vc = PageTabViewController()
            self.show(vc, sender: nil)
        }))
        models.append(RowModel(title: "BarTabViewController", handler: { [unowned self] in
            let vc = BarTabViewController()
            self.show(vc, sender: nil)
        }))
        models.append(RowModel(title: "HeaderTabViewController", handler: { [unowned self] in
            let vc = HeaderTabViewController()
            self.show(vc, sender: nil)
        }))
        return models
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.rowModels[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.rowModels[indexPath.row].handler()
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
