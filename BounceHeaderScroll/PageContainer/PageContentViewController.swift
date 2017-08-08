//
//  PageContentViewController.swift
//  PageControllerContainer
//
//  Created by nyato on 2017/8/3.
//  Copyright © 2017年 nyato. All rights reserved.
//

import UIKit

protocol PageContentViewControllerDelegate: class {
    func pageContentViewController(_ controller: PageContentViewController, didSelectedAt page: Int)
}

class PageContentViewController: UIViewController {
    
    
    // MARK: Public
    var pageIndex = 0

    weak var delegate: PageContentViewControllerDelegate?
    
    var imageFile: String?
    var pageTitle: String?
    
    // MARK: - View Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(tap)
    }
    
    private var added = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !added {
            added = true
            
            setImageView()
            setPageTitle()
        }
    }
        
    // MARK: - Helper
    
    @objc private func tapGesture() {
        delegate?.pageContentViewController(self, didSelectedAt: pageIndex)
    }
    
    private func setImageView() {
        let imageView = UIImageView(frame: view.bounds)
        view.addSubview(imageView)
        if imageFile != nil {
            imageView.image = UIImage(named: imageFile!)
        }
    }
    
    private func setPageTitle() {
        let titleLabel = UILabel(frame: view.bounds)
        titleLabel.center = view.center
        titleLabel.text = pageTitle
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 50)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
    }
}
