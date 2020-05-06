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
    private var menuHeaderView: MenuHeaderView!
    private var pageVC: PageViewController!

    let menus: [Menu] = {
        [Menu(id: 11, title: "野球部"),
         Menu(id: 31, title: "バスケットボール部"),
         Menu(id: 24, title: "サッカー部"),
         Menu(id: 38, title: "吹奏楽部"),
         Menu(id: 9, title: "登山部"),
         Menu(id: 40, title: "バドミントン部"),
         Menu(id: 51, title: "バレー部"),
         Menu(id: 8, title: "柔道部"),
         Menu(id: 6, title: "ハンドボール部"),
         Menu(id: 90, title: "陸上部"),]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        menuHeaderView = MenuHeaderView.make(frame: CGRect(origin: .zero, size: menuHeaderBaseView.frame.size),
                                             menus: menus,
                                             selectMenuTitleColor: .red)
        menuHeaderView.delegate = self
        menuHeaderBaseView.addSubview(menuHeaderView)
    }

    // コンテナView内部VCの処理（初期設定等）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let pageVC = segue.destination as? PageViewController,
            segue.identifier == "EmbedPageVC" else {
            return
        }

        self.pageVC = pageVC
        self.pageVC.pageViewControllerDelegate = self
        self.pageVC.setup(vcArray: menus.map {
            let contentVC = ContentViewController(centerTitle: $0.title)
            contentVC.view.tag = $0.id
            return contentVC
        })
    }
}

extension ViewController: PageViewControllerDelegate {
    func didPagingForSwipe(pageId: Int) {
        menuHeaderView.selectMenu(at: pageId)
    }
}

extension ViewController: MenuHeaderViewDelegate {
    func didTapMenu(_ menu: Menu) {
        pageVC.setPage(at: menu.id)
    }
}
