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
    /// - Parameter pageId: 遷移先のページ番号（Menu.id）
    func didPagingForSwipe(pageId: Int)
}

class PageViewController: UIPageViewController {

    // ページングするVCの管理用
    private var vcArray = [UIViewController]()
    private var pageIndex = 0
    weak var pageViewControllerDelegate: PageViewControllerDelegate?

    /// 初期設定
    /// - Parameters:
    ///   - vcArray: ページングさせるVCの配列
    ///   - firstPageIndex: 最初に表示させるVC要素に関する配列内のIndex
    func setup(vcArray: [UIViewController], firstPageIndex: Int) {
        self.dataSource = self
        self.delegate = self
        self.vcArray = vcArray
        pageIndex = firstPageIndex
        setViewControllers([vcArray[firstPageIndex]], direction: .forward, animated: true, completion: nil)
    }

    /// menuIdに対応するページに遷移する（ページングする、手動以外の遷移のために用意）
    /// - Parameter menuId: menuId
    func setPage(at menuId: Int) {
        guard let nextPageIndex = pageIndex(at: menuId) else { return }
        let direction: NavigationDirection = nextPageIndex > pageIndex ? .forward : .reverse
        pageIndex = nextPageIndex
        setViewControllers([vcArray[nextPageIndex]], direction: direction, animated: true, completion: nil)
    }

    /// menuIdに対応したページ数(Index)を返す
    /// - Parameter menuId: menuId
    private func pageIndex(at menuId: Int) -> Int? {
        vcArray.firstIndex(where: { $0.view.tag == menuId })
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    // 右スワイプ
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let nextVC = vcArray[safe: pageIndex - 1] else { return nil }
        return nextVC
    }

    // 左スワイプ
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let nextVC = vcArray[safe: pageIndex + 1] else { return nil }
        return nextVC
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // setViewControllersを呼んでの遷移の場合は呼ばれない、スワイプのみ
        if finished, completed, let currentVC = pageViewController.viewControllers?.first,
            let currentPageIndex = pageIndex(at: currentVC.view.tag) {
            // ページング後に表示しているページ番号を更新
            pageIndex = currentPageIndex
            pageViewControllerDelegate?.didPagingForSwipe(pageId: currentVC.view.tag)
        }
    }
}
