//
//  PageViewController.swift
//  Paging-Menu-Sample
//
//  Created by kawaharadai on 2020/05/05.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate: AnyObject {
    /// スワイプ 動作によってページングされた
    /// - Parameter pageNumber: 遷移先のページ番号（Menu.id）
    func didPagingForSwipe(pageNumber: Int)
}

class PageViewController: UIPageViewController {

    // ページングするVCの管理用
    private var contentVCDicAtMenuId: [Int : ContentViewController] = [:]
    weak var pageViewControllerDelegate: PageViewControllerDelegate?

    func setup(firstMenuId: Int, contentVCDicAtMenuId: [Int : ContentViewController]) {
        self.dataSource = self
        self.delegate = self
        self.contentVCDicAtMenuId = contentVCDicAtMenuId
        guard let firstVC = self.contentVCDicAtMenuId[firstMenuId] else { return }
        setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
    }

    func setPage(at pageNumber: Int) {
        guard let nextPage = contentVCDicAtMenuId[pageNumber],
            let currentPage = viewControllers?.first else { return }

        setViewControllers([nextPage], direction: nextPage.view.tag > currentPage.view.tag ? .forward : .reverse,
                           animated: true, completion: nil)
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    // 右スワイプ
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let result = contentVCDicAtMenuId
            .filter { viewController.view.tag > $0.key } // 表示中のVCよりidが小さい(昇順なので右側)ものを絞る
            .max { $0.key < $1.key } // 中で一番idが大きい（表示中のVCに近いページを持つdic）ものを確定
        return result?.value
    }

    // 左スワイプ
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let result = contentVCDicAtMenuId
            .filter { $0.key > viewController.view.tag } // 表示中のVCよりidが大きい(昇順なので左側)ものを絞る
            .min { $0.key < $1.key } // 中で一番idが小さい（表示中のVCに近いページを持つdic）ものを確定
        return result?.value
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished, completed, let currentVC = pageViewController.viewControllers?.first {
            pageViewControllerDelegate?.didPagingForSwipe(pageNumber: currentVC.view.tag)
        }
    }
}
