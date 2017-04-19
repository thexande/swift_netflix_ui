//
//  ViewController.swift
//  netflix_ui
//
//  Created by Alex Murphy on 4/18/17.
//  Copyright © 2017 Alex Murphy. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.green
        TelevisionEpisodeHelper.getTVEpisodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

