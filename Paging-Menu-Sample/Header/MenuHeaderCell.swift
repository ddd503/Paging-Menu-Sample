//
//  MenuHeaderCell.swift
//  Paging-Menu-Sample
//
//  Created by kawaharadai on 2020/05/05.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

class MenuHeaderCell: UICollectionViewCell {

    @IBOutlet weak private var titleLabel: UILabel!

    func setInfo(title: String) {
        titleLabel.text = title
    }
    /// タイトルカラーを変更する
    /// - Parameter color: タイトルカラー
    func setTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
}
