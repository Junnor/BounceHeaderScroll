//
//  MainViewController.swift
//  BounceHeaderScroll
//
//  Created by nyato on 2017/8/8.
//  Copyright © 2017年 nyato. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = cellHeight
            
            tableView.register(UINib(nibName: "ContentCell", bundle: nil),
                               forCellReuseIdentifier: "ContentCell")
        }
    }
    
    private var pageContainer: PageContainerController!
    fileprivate var headerView: UIView!
    fileprivate var customStatusBar: UIView!
    
    fileprivate var scrollHeaderViewUp = true
    fileprivate var preferredLightStatusBar = true
    
    fileprivate let cellWidth = UIScreen.main.bounds.width
    fileprivate let cellHeight = UIScreen.main.bounds.width * 45 / 80
    fileprivate let maxShadowAlpha: CGFloat = 0.5
    fileprivate let statusBarHeight: CGFloat = 20
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return preferredLightStatusBar ? .lightContent : .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureStatusBar()
        configureHeaderView()
    }
    
    // MARK: - Helper
    
    private func configureStatusBar() {
        
        let frame = CGRect(x: 0, y: 0, width: cellWidth, height: statusBarHeight)
        customStatusBar = UIView(frame: frame)
        customStatusBar.backgroundColor = UIColor.white
        customStatusBar.isHidden = true
        view.insertSubview(customStatusBar, aboveSubview: tableView)
    }
    
    private func configureHeaderView() {
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight * 4/3))
        headerView.backgroundColor = UIColor.gray
        
        pageContainer = PageContainerController(useTimer: false,
                                                recursive: true,
                                                showTitle: true)
        addChildViewController(pageContainer)
        pageContainer.delegate = self
        
        pageContainer.pageImageFiles = ["5", "4", "3"]
        pageContainer.pageTitles = ["Page 0", "Page 1", "Page 2"]
        
        let frame = headerView.bounds
        pageContainer.view.frame = frame
        headerView.addSubview(pageContainer.view)
        
        pageContainer.didMove(toParentViewController: self)
        
        tableView.tableHeaderView = headerView
    }
    
    @objc private func tap(gesture: UITapGestureRecognizer) {
        print("tap in header view")
    }
    
}


extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
        
        if let cell = cell as? ContentCell {
            cell.contentImageView.image = UIImage(named: "\(indexPath.item)")
            cell.titleLabel.text = "\(indexPath.item)"
        }
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("table view row: \(indexPath.row)")
        
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        var transform = CATransform3DIdentity
//        
//        if offsetY < 0 {
//            let headerScaleFactor = -offsetY / 100
//            print("-offsetY = \(-offsetY)")
//            print("self.headerView.bounds.size.height: \(self.headerView.bounds.size.height)")
//            print("headerScaleFactor: \(headerScaleFactor)")
//            transform = CATransform3DTranslate(transform, 0, -offsetY, 0)
//            transform = CATransform3DScale(transform,
//                                                 1.0 + 2 * headerScaleFactor,
//                                                 1.0 + 2 * headerScaleFactor,
//                                                 0)
//            
//            self.headerView.layer.transform = transform
//            
//        } else {
//            if !scrollHeaderViewUp {
//                transform = CATransform3DTranslate(transform, 0, offsetY, 0)
//                self.headerView.layer.transform = transform
//            }
//            
//            // 设置 status bar 不同风格
//            let tmpHeaderFactor = offsetY / self.headerView.bounds.size.height
//            configureStatusBar(with: tmpHeaderFactor)
//        }
//    }
    
    private func configureStatusBar(with value: CGFloat) {
        if self.customStatusBar.isHidden && value > 1.0 {
            customStatusBar.isHidden = false
            preferredLightStatusBar = false
        }
        
        if !self.customStatusBar.isHidden && value <= 1.0 {
            customStatusBar.isHidden = true
            self.preferredLightStatusBar = true
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
}


extension MainViewController: PageContainerControllerDelegate {
    
    func pageContainerController(_ controller: PageContainerController, didSelectedAt page: Int) {
        print("selected page container index: \(page) ")
    }
    
}

