//
//  SwipeSegue.swift
//  CustomSegue
//
//  Created by Ju on 2017/6/4.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate: class {
    func pageViewController(_ pageViewController: PageViewController, didSelectedAt page: Int)
}

class PageViewController: UIViewController {
    
    // MARK: Public
    weak var delegate: PageViewControllerDelegate?

    var allowedRecursive = true
    var useTimerAnimation = true
    var isPageControllerValueChangeAvailable = false
    
    var hidePageController = false {
        didSet {
            pageController?.isHidden = hidePageController
        }
    }
    
    var usePageTitle = false
    
    /*
 
     之所以 imagesName & pagesTitle 这样出来是因为图片可能通过网络加载
     */
    var pageImageFiles: [String] = [] {
        didSet {
            if usePageTitle && pageTitles.count == 0 {  // 判断是否使用标题
                return
            }
            
            if pageImageFiles.count > 0 && !configuredPageView {
                initializerPageView()
            }
        }
    }
    
    var pageTitles: [String] = [] {
        didSet {
            if pageTitles.count > 0 && pageImageFiles.count > 0 && !configuredPageView {
                initializerPageView()
                
                numberOfPage = pageImageFiles.count
            }
        }
    }
    
    // MARK: Private

    private var pageViewController: UIPageViewController!
    fileprivate var pageController: UIPageControl!
    
    private var pageControllerHeight: CGFloat = 50
    private var lastPageIndex = 0
    fileprivate var numberOfPage = 0
    private let timeInterval = 5.0
    private let scrollAfterTime = 3.0

    // MARK: - View controller lifecycle
    private var configuredPageView = false
    private var timer: Timer!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        if pageImageFiles.count > 0 {
            if !configuredPageView {
                
                configuredPageView = true
                
                setPageViewController()
                setPageController()
                
                view.layoutIfNeeded()
            }
            
            // 第一次调用 viewDidAppear() 的时候不执行， 通过设置图片或者标题属性初始化 timer 
            if timer != nil && useTimerAnimation {
                DispatchQueue.main.asyncAfter(deadline: .now() + scrollAfterTime, execute: {
                    self.fireTimer()
                })
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if useTimerAnimation {
            self.invalidateTimer()
        }
    }

    
    // MARK: Helper
    
    private func initializerPageView() {
        configuredPageView = true
        
        numberOfPage = pageImageFiles.count
        
        setPageViewController()
        setPageController()
        
        view.layoutIfNeeded()

        if useTimerAnimation {
            DispatchQueue.main.asyncAfter(deadline: .now() + scrollAfterTime, execute: {
                self.fireTimer()
            })
        }
    }
    
    private func fireTimer() {
        timer?.invalidate()   // add it
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                          target: self,
                                          selector: #selector(scrollToNextController),
                                          userInfo: nil,
                                          repeats: true)
        timer?.fire()
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
    }
    
    private func setPageViewController() {
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let startingContentViewController = contentViewController(at: 0)
        let viewControllers = [startingContentViewController!]

        pageViewController.setViewControllers(viewControllers,
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
        
        pageViewController.view.frame = view.bounds
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }
    
    private func setPageController() {
        var frame = view.frame
        frame.origin.y = frame.height - 50
        frame.size.height = 50
        frame.size.width = min(CGFloat(pageImageFiles.count * 30), frame.width)
        pageController = UIPageControl(frame: frame)
        pageController.center.x = view.center.x
        
        pageController.numberOfPages = pageImageFiles.count
            
        if isPageControllerValueChangeAvailable {
            pageController.addTarget(self, action: #selector(valueChangeAction), for: .valueChanged)
        }
        
        view.addSubview(pageController)
        view.bringSubview(toFront: pageController)
        
        pageController.isHidden = hidePageController
    }
    
    @objc private func scrollToNextController() {
        var index = pageController.currentPage
        let num = numberOfPage
        
        if index >= (num - 1) {
            index = 0
        } else {
            index += 1
        }
        
        pageController.currentPage = index
        lastPageIndex = index
        
        let vc = [contentViewController(at: index)!]
        pageViewController.setViewControllers(vc,
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
    }

    
    @objc private func valueChangeAction() {
        let vc = contentViewController(at: pageController.currentPage)
        let viewControllers = [vc!]
        let direction: UIPageViewControllerNavigationDirection = pageController.currentPage > lastPageIndex ? .forward : .reverse
        
        lastPageIndex = pageController.currentPage
        
        pageViewController.setViewControllers(viewControllers,
                                              direction: direction,
                                              animated: true,
                                              completion: nil)
    }
    
    func contentViewController(at index: Int) -> UIViewController? {
        if numberOfPage == 0 || index >= numberOfPage {
            return nil
        }
        
        let contentViewControllr = PageContentViewController()
        contentViewControllr.delegate = self
        
        contentViewControllr.pageIndex = index
        contentViewControllr.imageFile = pageImageFiles[index]
        
        if usePageTitle {   // may not using page title
            contentViewControllr.pageTitle = pageTitles[index]
        }
        
        return contentViewControllr
    }

}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let vc = viewController as? PageContentViewController {
            var index = vc.pageIndex
            if index == NSNotFound { return nil }
            
            if allowedRecursive {
                if index <= 0 {
                    index = numberOfPage - 1
                } else {
                    index -= 1
                }
            } else {
                if index <= 0 {
                    return nil
                } else {
                    index -= 1
                }
            }
            
            return contentViewController(at: index)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let vc = viewController as? PageContentViewController {
            var index = vc.pageIndex
            if index == NSNotFound { return nil }
            
            if (self.allowedRecursive) {
                if index >= self.numberOfPage - 1 {
                    index = 0
                } else {
                    index += 1
                }
                return contentViewController(at: index)
            } else {
                if index >= self.numberOfPage - 1 {
                    return nil
                } else {
                    index += 1
                }
                
                return contentViewController(at: index)
            }
        }
        
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        let firstPageContentViewController = pendingViewControllers.first as? PageContentViewController
        if firstPageContentViewController != nil {
            let index = firstPageContentViewController!.pageIndex
            
            pageController.currentPage = index
        }
        
    }
    
}

// MARK: - page content delegate

extension PageViewController: PageContentViewControllerDelegate {
    func pageContentViewController(_ controller: PageContentViewController, didSelectedAt page: Int) {
        delegate?.pageViewController(self, didSelectedAt: page)
    }
}
