//
//  MenuHeaderView.swift
//  Paging-Menu-Sample
//
//  Created by kawaharadai on 2020/05/05.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

protocol MenuHeaderViewDelegate: AnyObject {
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
        // 初期表示時は(0,0)のセルに下線引く
        let cell = menuView.cellForItem(at: IndexPath(item: 0, section: 0)) as! MenuHeaderCell
        let bottomLineViewHeight = CGFloat(2)
        bottomLineView.frame = CGRect(x: 0,
                                      y: menuView.frame.height - bottomLineViewHeight,
                                      width: cell.frame.width,
                                      height: bottomLineViewHeight)
    }

    /// Menu.idを渡して任意のMenuを選択させる
    /// - Parameter menuId: Menu.id
    func selectMenu(at menuId: Int) {
        let result = menus.firstIndex { $0.id == menuId }
        guard let firstIndex = result else { return }
        collectionView(menuView, didSelectItemAt: IndexPath(item: firstIndex, section: 0))
    }
}

extension MenuHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        menus.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuHeaderCell.identifier, for: indexPath) as! MenuHeaderCell
        cell.setInfo(title: menus[indexPath.row].title)
        return cell
    }
}

extension MenuHeaderView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 選択されたセルを中央に寄せる（ContentSize超える場合は超えないことを優先して止まる）
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        delegate?.didSelectMenu(menus[indexPath.item])

        let cell = menuView.cellForItem(at: indexPath) as! MenuHeaderCell

        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.bottomLineView.frame.origin.x = cell.frame.origin.x
            self.bottomLineView.frame.size.width = cell.frame.width
        }
    }
}
