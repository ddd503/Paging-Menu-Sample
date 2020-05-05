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

    func setPage(at menuId: Int) {
        guard let nextPageIndex = vcArray.firstIndex(where: { $0.view.tag == menuId }) else { return }

        let direction: NavigationDirection = nextPageIndex > pageIndex ? .forward : .reverse
        pageIndex = nextPageIndex
        setViewControllers([vcArray[nextPageIndex]], direction: direction, animated: true, completion: nil)
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    // 右スワイプ
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard  let nextVC = vcArray[safe: pageIndex - 1] else { return nil }
        pageIndex -= 1
        return nextVC
    }

    // 左スワイプ
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard  let nextVC = vcArray[safe: pageIndex + 1] else { return nil }
        pageIndex += 1
        return nextVC
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished, completed, let currentVC = pageViewController.viewControllers?.first {
            pageViewControllerDelegate?.didPagingForSwipe(pageNumber: currentVC.view.tag)
        }
    }
}
