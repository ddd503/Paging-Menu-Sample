//
//  ContentViewController.swift
//  Paging-Menu-Sample
//
//  Created by kawaharadai on 2020/05/05.
//  Copyright © 2020 kawaharadai. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak private var centerTitleLabel: UILabel!
    private let centerTitle: String

    init(centerTitle: String) {
        self.centerTitle = centerTitle
        super.init(nibName: "ContentViewController", bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        centerTitleLabel.text = centerTitle
    }

}
