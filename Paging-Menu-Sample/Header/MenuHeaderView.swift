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
        }
    }

    /// イニシャライザ
    /// - Parameters:
    ///   - frame: frame
    ///   - menus: リスト表示するメニューの配列
    ///   - firstSelectMenuIndex: 初期表示時に選択されているmenus内のIndex
    ///   - selectMenuTitleColor: 選択中のメニュータイトルの色
    static func make(frame: CGRect, menus: [Menu], firstSelectMenuIndex: Int, selectMenuTitleColor: UIColor) -> MenuHeaderView {
        let view = UINib(nibName: "MenuHeaderView", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as! MenuHeaderView
        view.frame = frame
        view.menus = menus
        view.firstSelectMenuIndex = firstSelectMenuIndex
        view.selectMenuTitleColor = selectMenuTitleColor
        return view
    }

    private var bottomLineView = UIView()
    private var menus = [Menu]()
    private var firstSelectMenuIndex = 0
    private var selectMenuTitleColor = UIColor.black
    weak var delegate: MenuHeaderViewDelegate?

    // Viewのレイアウト完了後のタイミング（サイズが確定している想定）
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let firstSelectIndexPath = IndexPath(item: firstSelectMenuIndex, section: 0)
        // 初期表示時のメニュー選択
        // 画面に表示されていないセルを初期選択表示させたい時は、scrollPositionで動かせばcellForItemAtが走るため選択済みのセルの色が反映されるため必須
        // 既に表示中の場合は遷移移動でのcellForItemAtは走らないので自前で色指定必要
        menuView.selectItem(at: firstSelectIndexPath, animated: false, scrollPosition: .centeredHorizontally)

        // セル下に選択状態を表す線Viewを追加
        let addBottomLineView: (UICollectionViewCell) -> ()  = { [unowned self] cell in
            let bottomLineViewHeight = CGFloat(2)
            self.bottomLineView.frame = CGRect(x: cell.frame.origin.x,
                                               y: self.menuView.frame.height - bottomLineViewHeight,
                                               width: cell.frame.width,
                                               height: bottomLineViewHeight)
            self.bottomLineView.backgroundColor = self.selectMenuTitleColor
            self.menuView.addSubview(self.bottomLineView)
        }

        if let firstSelectCell = menuView.cellForItem(at: firstSelectIndexPath) as? MenuHeaderCell {
            // 表示されているセルを使用
            firstSelectCell.setTitleColor(selectMenuTitleColor)
            addBottomLineView(firstSelectCell)
        } else if let firstSelectCell = menuView.dequeueReusableCell(withReuseIdentifier: MenuHeaderCell.identifier,
                                                                     for: firstSelectIndexPath) as? MenuHeaderCell {
            // 該当のセルが表示されていないため再利用で作り直して使う
            addBottomLineView(firstSelectCell)
        }
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
        let titleColor: UIColor = menuView.indexPathsForSelectedItems?.first == indexPath ? selectMenuTitleColor : .black
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

        selectCell.setTitleColor(selectMenuTitleColor)

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
