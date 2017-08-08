//
//  PageContainerController.swift
//  PageControllerContainer
//
//  Created by nyato on 2017/8/3.
//  Copyright © 2017年 nyato. All rights reserved.
//

import UIKit

protocol PageContainerControllerDelegate: class {
    func pageContainerController(_ controller: PageContainerController, didSelectedAt page: Int)
}

class PageContainerController: UIViewController {
    
    /*
     useTimer: 是否允许循环滚动
     recursive: 是否允许自动滚动
     showTitle: 是否显示标题
     */
    init(useTimer: Bool, recursive: Bool, showTitle: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        self.useTimerAnimation = useTimer
        self.allowedRecursive = recursive
        self.usePageTitle = showTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    weak var delegate: PageContainerControllerDelegate?
    
    // 图片文件数组
    var pageImageFiles: [String] = [] {
        didSet {
            pageViewController?.pageImageFiles = pageImageFiles
        }
    }
    
    // 标题数组
    var pageTitles: [String] = [] {
        didSet {
            pageViewController?.pageTitles = pageTitles
        }
    }
    
    // 隐藏 pageController [滚动的小点点]， 默认显示
    var hidePageController = false {
        didSet {
            pageViewController?.hidePageController = hidePageController
        }
    }

    // 点击 pageController 小点点 的事件响应， 默认不允许
    var isPageControllerValueChangeAvailable = false {
        didSet {
            pageViewController?.isPageControllerValueChangeAvailable = isPageControllerValueChangeAvailable
        }
    }

    
    // MARK: Private
    
    // 允许循环滚动， 默认允许
    private var allowedRecursive = true {
        didSet {
            pageViewController?.allowedRecursive = allowedRecursive
        }
    }
    
    // 允许自动滚动，默认允许
    private var useTimerAnimation = true {
        didSet {
            pageViewController?.useTimerAnimation = useTimerAnimation
        }
    }
    
    // 使用标题，默认不显示
    private var usePageTitle = false {
        didSet {
            pageViewController?.usePageTitle = usePageTitle
        }
    }
    
    private var pageViewController: PageViewController!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        pageViewController = PageViewController()
        pageViewController.delegate = self
        
        addChildViewController(pageViewController)
        pageViewController.view.frame = view.bounds
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }
    
    
    private var showedView = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !showedView {
            showedView = true
            
            pageViewController?.allowedRecursive = self.allowedRecursive
            pageViewController?.hidePageController = self.hidePageController
            pageViewController?.useTimerAnimation = self.useTimerAnimation
            pageViewController?.usePageTitle = usePageTitle
            
            pageViewController?.pageImageFiles = self.pageImageFiles
            pageViewController?.pageTitles = self.pageTitles
        }
    }
    
}

// MARK: - pageView delegate

extension PageContainerController: PageViewControllerDelegate {
    func pageViewController(_ pageViewController: PageViewController, didSelectedAt page: Int) {
        delegate?.pageContainerController(self, didSelectedAt: page)
    }
}
