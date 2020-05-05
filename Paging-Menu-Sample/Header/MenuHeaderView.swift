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
    func didSelectMenu(_ menu: Menu)
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
            menuView.addSubview(bottomLineView)
        }
    }

    static func make(frame: CGRect, menus: [Menu]) -> MenuHeaderView {
        let view = UINib(nibName: "MenuHeaderView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as! MenuHeaderView
        view.frame = frame
        view.menus = menus
        return view
    }

    private var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    private var menus = [Menu]()
    weak var delegate: MenuHeaderViewDelegate?

    // Viewのレイアウト完了後のタイミング（サイズが確定している想定）
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // 見た目調整
        let firstSelectIndexPath = IndexPath(item: 0, section: 0)
        guard let firstSelectCell = menuView.cellForItem(at: firstSelectIndexPath) as? MenuHeaderCell else { return }

        let bottomLineViewHeight = CGFloat(2)
        bottomLineView.frame = CGRect(x: 0,
                                      y: menuView.frame.height - bottomLineViewHeight,
                                      width: firstSelectCell.frame.width,
                                      height: bottomLineViewHeight)

        firstSelectCell.setTitleColor(.red)

        // 見た目だけでなく内部状態も初期表示の時点で選択状態にしておく
        menuView.selectItem(at: firstSelectIndexPath, animated: false, scrollPosition: .init())
    }

    /// Menu.idを渡して任意のMenuを選択させる
    /// - Parameter menuId: Menu.id
    func selectMenu(at menuId: Int) {
        let result = menus.firstIndex { $0.id == menuId }
        guard let firstIndex = result, let currentSelectIndexPath = menuView.indexPathsForSelectedItems?.first else { return }

        menuView.deselectItem(at: currentSelectIndexPath, animated: false)
        collectionView(menuView, didDeselectItemAt: currentSelectIndexPath)

        let nextSelectIndexPath = IndexPath(item: firstIndex, section: 0)
        menuView.selectItem(at: nextSelectIndexPath, animated: true, scrollPosition: .init())
        collectionView(menuView, didSelectItemAt: nextSelectIndexPath)
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
        let titleColor: UIColor = menuView.indexPathsForSelectedItems?.first == indexPath ? .red : .black
        cell.setTitleColor(titleColor)
        return cell
    }
}

extension MenuHeaderView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 選択されたセルを中央に寄せる（ContentSize超える場合は超えないことを優先して止まる）
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        delegate?.didSelectMenu(menus[indexPath.item])

        guard let selectCell = menuView.cellForItem(at: indexPath) as? MenuHeaderCell else { return }

        selectCell.setTitleColor(.red)

        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.bottomLineView.frame.origin.x = selectCell.frame.origin.x
            self.bottomLineView.frame.size.width = selectCell.frame.width
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let deSelectCell = menuView.cellForItem(at: indexPath) as? MenuHeaderCell else { return }
        deSelectCell.setTitleColor(.black)
    }
}
