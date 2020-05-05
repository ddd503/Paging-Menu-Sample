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
        menuHeaderView = MenuHeaderView.make(frame: CGRect(origin: .zero, size: menuHeaderBaseView.frame.size), menus: menus)
        menuHeaderView.delegate = self
        menuHeaderBaseView.addSubview(menuHeaderView)
    }

    // コンテナView内部VCの処理（初期設定等）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let pageVC = segue.destination as? PageViewController,
            segue.identifier == "EmbedPageVC" else {
            return
        }
        let firstMenuId = menus.map { $0.id }.sorted { $0 < $1 }.min() ?? 0
        var contentVCDicAtMenuId: [Int : ContentViewController] = [:]
        menus.forEach {
            let contentVC = ContentViewController(centerTitle: $0.title)
            contentVC.view.tag = $0.id
            contentVCDicAtMenuId[$0.id] = contentVC
        }

        self.pageVC = pageVC
        self.pageVC.setup(firstMenuId: firstMenuId, contentVCDicAtMenuId: contentVCDicAtMenuId)
        self.pageVC.pageViewControllerDelegate = self
    }
}

extension ViewController: PageViewControllerDelegate {
    func didPagingForSwipe(pageNumber: Int) {
        menuHeaderView.selectMenu(at: pageNumber)
    }
}

extension ViewController: MenuHeaderViewDelegate {
    func didSelectMenu(_ menu: Menu) {
        pageVC.setPage(at: menu.id)
    }
}
