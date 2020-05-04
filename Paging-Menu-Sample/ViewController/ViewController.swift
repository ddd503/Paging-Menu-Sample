//
//  ViewController.swift
//  Paging-Menu-Sample
//
//  Created by kawaharadai on 2020/05/05.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak private var menuHeaderBaseView: UIView!

    let menus: [Menu] = {
        [Menu(id: 0, title: "野球部"),
         Menu(id: 1, title: "バスケットボール部"),
         Menu(id: 2, title: "サッカー部"),
         Menu(id: 3, title: "吹奏楽部"),
         Menu(id: 4, title: "バドミントン部"),
         Menu(id: 5, title: "バレー部"),
         Menu(id: 6, title: "柔道部"),
         Menu(id: 7, title: "ハンドボール部")]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let menuHeaderView = MenuHeaderView.make(frame: CGRect(origin: .zero, size: menuHeaderBaseView.frame.size), menus: menus)
        menuHeaderBaseView.addSubview(menuHeaderView)
    }

}

