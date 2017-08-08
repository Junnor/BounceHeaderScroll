//
//  ViewController.swift
//  BounceHeaderScroll
//
//  Created by nyato on 2017/8/8.
//  Copyright © 2017年 nyato. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            
            collectionView.register(UICollectionViewCell.self,
                                    forCellWithReuseIdentifier: "ClearHeaderCell")
            
            collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: "Cell")
            
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
                collectionView.collectionViewLayout = layout
            }
        }
    }
    
    
    private var pageContainer: PageContainerController!
    fileprivate var headerView: HeaderView!
    fileprivate var customStatusBar: UIView!
    
    fileprivate let zPostionForHeaderView: CGFloat = -1
    
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
        configurePageContainer()
    }
    
    // MARK: - Helper
    
    private func configureStatusBar() {
        
        let frame = CGRect(x: 0, y: 0, width: cellWidth, height: statusBarHeight)
        customStatusBar = UIView(frame: frame)
        customStatusBar.backgroundColor = UIColor.white
        customStatusBar.isHidden = true
        view.insertSubview(customStatusBar, aboveSubview: collectionView)
    }
    
    private func configureHeaderView() {
        headerView = Bundle.main.loadNibNamed("HeaderView", owner: nil, options: nil)?.first as! HeaderView
        headerView.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        headerView.addGestureRecognizer(tap)
            
        headerView.layer.zPosition = zPostionForHeaderView
        
        collectionView.insertSubview(headerView, at: 0)
    }
    
    @objc private func tap(gesture: UITapGestureRecognizer) {
        print("tap in header view")
    }
    
    private func configurePageContainer() {
        pageContainer = PageContainerController(useTimer: true,
                                                recursive: true,
                                                showTitle: true)
//        addChildViewController(pageContainer)
        pageContainer.delegate = self
        pageContainer.pageImageFiles = ["5", "4", "3"]
        pageContainer.pageTitles = ["Page 0", "Page 1", "Page 2"]
        
        let frame = headerView.bounds
        pageContainer.view.frame = frame
        headerView.addSubview(pageContainer.view)
        
        // 如果把 pageContainer 加进去 事件响应会直接在 Collection View Cell，所以就不加了
//        pageContainer.didMove(toParentViewController: self)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContentDetail" {
            let desvc = segue.destination as! DetailViewController
            let indexPath = collectionView.indexPathsForSelectedItems![0]
            desvc.image = UIImage(named: "\(indexPath.item)")
        }
    }
    
    @IBAction func unwindToViewController(_ segue: UIStoryboardSegue) {
    }
}


extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 + 1   // 1 为透明 Cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseCellIdentifer = indexPath.row == 0 ? "ClearHeaderCell" : "Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellIdentifer, for: indexPath)
        if let cell = cell as? CollectionViewCell {
            cell.imageView.image = UIImage(named: "\(indexPath.item)")
            cell.titleLabel.text = "\(indexPath.item)"
        } else {
            headerView.backgroundColor = UIColor.clear
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected collection item: \(indexPath.row)")
        performSegue(withIdentifier: "ContentDetail", sender: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        var headerTransform = CATransform3DIdentity
        
        if offsetY < 0 {
            var headerScaleFactor = -offsetY / self.headerView.bounds.size.height
            headerTransform = CATransform3DTranslate(headerTransform, 0, offsetY, zPostionForHeaderView)
            headerTransform = CATransform3DScale(headerTransform,
                                                 1.0 + 2 * headerScaleFactor,
                                                 1.0 + 2 * headerScaleFactor,
                                                 zPostionForHeaderView)

            self.headerView.layer.transform = headerTransform
            
            // !self.scrollHeaderViewUp 条件下 header view 的阴影效果
            if !self.scrollHeaderViewUp && self.headerView.shadowView.alpha > 0.0 {
                headerScaleFactor = -headerScaleFactor * maxShadowAlpha
                let currentAlpha = self.headerView.shadowView.alpha
                self.headerView.shadowView.alpha = currentAlpha + headerScaleFactor
            }
        } else {
            if !scrollHeaderViewUp {
                headerTransform = CATransform3DTranslate(headerTransform, 0, offsetY, zPostionForHeaderView)
                self.headerView.layer.transform = headerTransform
                
                let headerFactor = offsetY / self.headerView.bounds.size.height * maxShadowAlpha
                if headerFactor <= maxShadowAlpha {
                    self.headerView.shadowView.alpha = headerFactor
                }
            }
            
            // 设置 status bar 不同风格
            let tmpHeaderFactor = offsetY / self.headerView.bounds.size.height
            configureStatusBar(with: tmpHeaderFactor)
        }
    }
    
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

extension ViewController: PageContainerControllerDelegate {
    
    func pageContainerController(_ controller: PageContainerController, didSelectedAt page: Int) {
        print("selected page container index: \(page) ")
    }
    
}


// MARK: - ViewHeadabel protocol

extension ViewController: ViewHeadabel {
    
    var animatedViewFrame: CGRect {
        let attribute = collectionView.layoutAttributesForItem(at: collectionView.indexPathsForSelectedItems![0])
        let cellRect = attribute?.frame
        let animatedFrame = collectionView?.convert((cellRect)!, to: collectionView.superview)
        
        return animatedFrame!
    }
    
}
