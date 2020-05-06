//
//  MenuHeaderView.swift
//  Paging-Menu-Sample
//
//  Created by kawaharadai on 2020/05/05.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

protocol MenuHeaderViewDelegate: AnyObject {
    /// 任意のメニューが選択(タップ)された
    /// - Parameter menu: 選択されたメニュー(Menu)
    func didTapMenu(_ menu: Menu)
}

class MenuHeaderView: UIView {

    @IBOutlet weak private var menuView: UICollectionView! {
        didSet {
            menuView.dataSource = self
            menuView.delegate = self
            menuView.register(MenuHeaderCell.nib(), forCellWithReuseIdentifier: MenuHeaderCell.identifier)
            let layout = UICollectionViewFlowLayout()
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.scrollDirection = .horizontal
            menuView.collectionViewLayout = layout
        }
    }

    /// イニシャライザ
    /// - Parameters:
    ///   - frame: frame
    ///   - menus: リスト表示するメニューの配列
    ///   - selectMenuTitleColor: 選択中のメニュータイトルの色
    static func make(frame: CGRect, menus: [Menu], selectMenuTitleColor: UIColor) -> MenuHeaderView {
        let view = UINib(nibName: "MenuHeaderView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as! MenuHeaderView
        view.frame = frame
        view.menus = menus
        view.selectMenuTitleColor = selectMenuTitleColor
        return view
    }

    private var bottomLineView = UIView()
    private var menus = [Menu]()
    private var selectMenuTitleColor = UIColor.black
    weak var delegate: MenuHeaderViewDelegate?

    // Viewのレイアウト完了後のタイミング（サイズが確定している想定）
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let firstSelectIndexPath = IndexPath(item: 0, section: 0)
        // 選択状態を表す下線Viewを追加
        bottomLineView.backgroundColor = selectMenuTitleColor
        bottomLineView.frame = bottomLineViewFrame(by: firstSelectIndexPath)
        menuView.addSubview(bottomLineView)
        // 初期表示時のメニュー選択
        selectMenu(at: firstSelectIndexPath, animated: false)
    }

    /// Menu.idを渡して任意のMenuを選択させる
    /// - Parameter menuId: Menu.id
    func selectMenu(at menuId: Int) {
        guard let selectIndexPath = menuIndex(at: menuId) else { return }
        // 選択済みのメニューがあれば選択解除
        deselectMenuIfNeeded()
        // 選択処理
        selectMenu(at: selectIndexPath)
    }

    /// IndexPathからセルが選択された場合の下線ViewのFrameを返す
    /// - Parameter indexPath: IndexPath
    private func bottomLineViewFrame(by indexPath: IndexPath) -> CGRect {
        let selectCell = menuView.cellForItem(at: indexPath) ?? menuView.dequeueReusableCell(withReuseIdentifier: MenuHeaderCell.identifier, for: indexPath)
        let bottomLineViewHeight = CGFloat(2)
        return CGRect(x: selectCell.frame.origin.x,
                      y: menuView.frame.height - bottomLineViewHeight,
                      width: selectCell.frame.width,
                      height: bottomLineViewHeight)
    }

    /// menuIdに対応したメニューの表示位置（IndexPath）
    /// - Parameter menuId: menuId
    private func menuIndex(at menuId: Int) -> IndexPath? {
        let result = menus.firstIndex { $0.id == menuId }
        guard let index = result else { return nil }
        return IndexPath(row: index, section: 0)
    }

    private func selectMenu(at indexPath: IndexPath, animated: Bool = true) {
        guard let selectCell = menuHeaderCellForItem(at: indexPath) else { return }
        // この処理後にデリゲートメソッド（didSelectItemAt）を呼ばないからdidSelectItemAtから読んでも大丈夫
        menuView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
        selectCell.setTitleColor(selectMenuTitleColor)
        moveBottomLine(at: indexPath, animated: true)
    }

    private func deselectMenuIfNeeded(at indexPath: IndexPath? = nil) {
        guard let deselectIndexPath = indexPath ?? menuView.indexPathsForSelectedItems?.first,
            let deselectCell = menuHeaderCellForItem(at: deselectIndexPath) else { return }
        // この処理後にデリゲートメソッド（didDeselectItemAt）を呼ばないからdidDeselectItemAtから読んでも大丈夫
        menuView.deselectItem(at: deselectIndexPath, animated: false)
        deselectCell.setTitleColor(.black)
    }

    /// IndexPath指定でMenuHeaderCellを取得する
    /// - Parameter indexPath: IndexPath
    private func menuHeaderCellForItem(at indexPath: IndexPath) -> MenuHeaderCell? {
        // 表示されているセル取得用で取れなければ、再利用手法で作り直して返す
        menuView.cellForItem(at: indexPath) as? MenuHeaderCell ??
            menuView.dequeueReusableCell(withReuseIdentifier: MenuHeaderCell.identifier, for: indexPath) as? MenuHeaderCell
    }

    /// 指定したIndexPathのセルに下線を移動させる
    /// - Parameter indexPath: IndexPath
    /// - Parameter animated: 移動時にアニメーションさせるか
    private func moveBottomLine(at indexPath: IndexPath, animated: Bool) {
        let execute = { [unowned self] in
            self.bottomLineView.frame = self.bottomLineViewFrame(by: indexPath)
        }
        animated ? UIView.animate(withDuration: 0.2, animations: execute) : execute()
    }
}

extension MenuHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        menus.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuHeaderCell.identifier, for: indexPath) as! MenuHeaderCell
        cell.setInfo(title: menus[indexPath.row].title)
        // 選択中のセルはタイトル赤色、それ以外は黒色（else側は再利用対応）
        let titleColor: UIColor = menuView.indexPathsForSelectedItems?.first == indexPath ? selectMenuTitleColor : .black
        cell.setTitleColor(titleColor)
        return cell
    }
}

extension MenuHeaderView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectMenu(at: indexPath)
        delegate?.didTapMenu(menus[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        deselectMenuIfNeeded(at: indexPath)
    }
}
