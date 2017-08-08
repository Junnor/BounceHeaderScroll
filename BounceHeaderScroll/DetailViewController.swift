//
//  DetailViewController.swift
//  CustomSegue
//
//  Created by Ju on 2017/6/4.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var image: UIImage! {
        didSet {
            configureImageView()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageView()
    }

    @IBOutlet var imageswipeGestureDown: UISwipeGestureRecognizer!

    private func configureImageView() {
        if let image = image {
            imageView?.image = image
        }
    }

 }

extension DetailViewController: ViewSwipeable {
    
    var direction: UISwipeGestureRecognizerDirection {
        return imageswipeGestureDown.direction
    }
}
