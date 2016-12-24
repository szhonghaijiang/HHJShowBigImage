//
//  HMShowBigImageView.swift
//  TableView_Swift
//
//  Created by szulmj on 16/3/12.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

typealias TextBlock = (_ index: Int) -> String

private var HHJShowBigScreenWidth: CGFloat { return UIScreen.main.bounds.size.width }
private var HHJShowBigScreenHeight: CGFloat { return UIScreen.main.bounds.size.height}

public class HMShowBigImageView: UIView, UIScrollViewDelegate {
    private var pageCount: HHJPageControl!
    private var images: [UIImage]!
    private var imageViews: [UIImageView]!
    private var scrollImageVies: [UIImageView]!
    
    /// 底部pageControl的颜色
    var HHJCurrentPageIndicatorTintColor: UIColor!
    var HHJpageIndicatorTintColor: UIColor!
    
    
    /// 背景颜色，默认是 UIColor.black.withAlphaComponent(0.75)
    var HHJBackColor: UIColor! {
        didSet {
            bacgView.backgroundColor = HHJBackColor
        }
    }
    
    /// 图片间隔
    var HHJScrollImageViewHorizonGap: CGFloat!
    
    private var imageScroll: UIScrollView!
    private let bacgView = UIView()
    
    /// 是否显示状态栏
    var hiddenStatusBar = false {
        didSet {
            layoutIfNeeded()
            myWindow.windowLevel = hiddenStatusBar ? UIWindowLevelStatusBar + 1 : UIWindowLevelNormal
        }
    }
    
    /// 顶部文字出现的block，如果实现了这个block，则会隐藏底部pageControl
    var labelTextBlock: TextBlock? {
        didSet {
            pageCount.isHidden = labelTextBlock != nil
        }
    }
    
    //顶部文字控件
    private lazy var topLbale: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: HHJShowBigScreenWidth, height: 64))
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        self.addSubview(label)
        return label
    }()
    
    /// 顶部文字的底部图片
    var topLabelImage: UIImage? {
        didSet {
            if let img = topLabelImage {
                let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: HHJShowBigScreenWidth, height: 64))
                iv.image = img
                self.topLbale.addSubview(iv)
            }
        }
    }
    
    /// 图片的contentMode
    var HHJContentMode = UIViewContentMode.scaleAspectFill
    
    private let myWindow: UIWindow = {
        let wd = UIWindow(frame: UIScreen.main.bounds)
        wd.makeKeyAndVisible()
        return wd
    }()
    
    /// 显示的动画时长
    var showDuration = 0.5
    
    /// 是否允许图片缩放，默认允许
    var isCanScale = true
    
    /// 缩放的最大比例，默认是4倍
    var maxScale = CGFloat(4)
    
    /// 缩放的最小比例，默认是0.25
    var minScale = CGFloat(0.25)
    
    init?(imageViews: [UIImageView], currentIndex: Int) {
        super.init(frame: UIScreen.main.bounds)
        setDefaultParam()
        //先判断是否有图片，如果没有图片则返回
        if imageViews.isEmpty { return nil }
        
        self.imageViews = imageViews
        self.scrollImageVies = []
        HHJContentMode = self.imageViews[currentIndex].contentMode
        
        //创建一个 UIScrollView 用来放置 图片
        let imageScroll = creatScrollView()
        self.imageScroll = imageScroll
        self.addSubview(imageScroll)
        
        let scrollWith = imageScroll.bounds.size.width
        imageScroll.contentSize = CGSize(width: scrollWith * CGFloat(imageViews.count), height: imageScroll.bounds.size.height)
        
        for (index, originImageView) in imageViews.enumerated() {
            creatScrollImageView(image: nil, originImageView: originImageView, imageScroll: imageScroll, index: index)
        }
        
        if imageViews.count > 0 { creatPageController(numberOfPages: imageViews.count, currentPage: currentIndex) }
        
        imageScroll.contentOffset = CGPoint(x: scrollWith * min(CGFloat(currentIndex), CGFloat(imageViews.count - 1)), y: 0)
    }
    
    init?(originImages: [UIImage], currentIndex: Int) {
        super.init(frame: UIScreen.main.bounds)
        setDefaultParam()
        
        //先判断是否有图片，如果没有图片则返回
        if originImages.isEmpty { return nil }
        
        self.images = originImages
        self.scrollImageVies = []
        
        //创建一个 UIScrollView 用来放置 图片
        let imageScroll = creatScrollView()
        self.imageScroll = imageScroll
        self.addSubview(imageScroll)
        
        let scrollWith = imageScroll.bounds.size.width
        imageScroll.contentSize = CGSize(width: scrollWith * CGFloat(originImages.count), height: imageScroll.bounds.size.height)
        
        for (index, originImage) in originImages.enumerated() {
            creatScrollImageView(image: originImage, originImageView: nil, imageScroll: imageScroll, index: index)
        }
        
        if originImages.count > 0 { creatPageController(numberOfPages: originImages.count, currentPage: currentIndex) }
        
        imageScroll.contentOffset = CGPoint(x: scrollWith * min(CGFloat(currentIndex), CGFloat(originImages.count - 1)), y: 0)
    }
    
    
    func show() {
        showOrDismiss(show: true)
    }
    
    //frame: CGRect,
    private func creatScrollImageView(image: UIImage?, originImageView: UIImageView?, imageScroll: UIScrollView, index: Int) {
        let scrollWith = imageScroll.bounds.size.width
        let scorllHeight = imageScroll.bounds.size.height
        var tempImage: UIImage?
        if originImageView != nil {
            if let originImageViewImage = originImageView!.image {
                tempImage = originImageViewImage
            }
        } else {
            tempImage = image
        }
        let imageOriginSize = tempImage != nil ? tempImage!.size : CGSize(width: 0, height: 0)
        let imageSize = self.getFitSize(maxSize: CGSize(width: HHJShowBigScreenWidth, height: scorllHeight), orSize: imageOriginSize)
        let imageX = (HHJShowBigScreenWidth - imageSize.width) * 0.5
        let imageY = (scorllHeight - imageSize.height) * 0.5
        
        let imageView = UIImageView.init(frame: CGRect(x: CGFloat(index) * scrollWith + imageX, y: imageY, width: imageSize.width, height: imageSize.height))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HMShowBigImageView.imageTap)))
        imageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(HMShowBigImageView.imageScaleBig(gesture:))))
        
        imageView.image = tempImage
        scrollImageVies.append(imageView)
        imageScroll.addSubview(imageView)
    }
    
    /**
     创建一个UIScrollview
     */
    private func creatScrollView() -> UIScrollView {
        //获得屏幕长宽和状态栏高度
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let imageScroll = UIScrollView(frame: CGRect(x: 0, y: statusBarHeight, width: HHJShowBigScreenWidth + HHJScrollImageViewHorizonGap, height: HHJShowBigScreenHeight - statusBarHeight))
        imageScroll.showsHorizontalScrollIndicator = false
        imageScroll.isPagingEnabled = true
        imageScroll.backgroundColor = UIColor.clear
        imageScroll.delegate = self
        return imageScroll
    }
    
    /**
     创建一个HHJPageControl
     */
    private func creatPageController(numberOfPages: Int, currentPage: Int) {
        let pageCountBottomGap = 40.0
        let pageCountHeight = 20.0
        let pageCount = HHJPageControl(frame: CGRect(x: 0, y: Double(HHJShowBigScreenHeight) - pageCountBottomGap - pageCountHeight, width: Double(HHJShowBigScreenWidth), height: pageCountHeight))
        self.pageCount = pageCount
        pageCount.currentPageIndicatorTintColor = HHJCurrentPageIndicatorTintColor
        pageCount.pageIndicatorTintColor = HHJpageIndicatorTintColor
        self.addSubview(pageCount)
        
        pageCount.numberOfPages = numberOfPages
        pageCount.currentPage = currentPage
    }
    
    /**
     根据允许最大的尺寸，原始尺寸 按比例获得图片的尺寸
     */
    private func getFitSize(maxSize size: CGSize, orSize: CGSize) -> CGSize {
        if orSize.width == 0 || orSize.height == 0 { return size }
        
        let maxRaw = size.width / size.height
        let oriRaw = orSize.width / orSize.height
        
        var fixSize = CGSize()
        if maxRaw > oriRaw {
            fixSize.height = size.height
            fixSize.width = fixSize.height * oriRaw
        } else {
            fixSize.width = size.width
            fixSize.height = fixSize.width / oriRaw
        }
        return fixSize
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let statusBarHeight = hiddenStatusBar ? 0 : UIApplication.shared.statusBarFrame.size.height
        imageScroll.frame = CGRect(x: 0, y: statusBarHeight, width: HHJShowBigScreenWidth + HHJScrollImageViewHorizonGap, height: HHJShowBigScreenHeight - statusBarHeight)
        
        let scrollWith = imageScroll.bounds.size.width
        let scorllHeight = imageScroll.bounds.size.height
        imageScroll.contentSize = CGSize(width: scrollWith * CGFloat(scrollImageVies.count), height: imageScroll.bounds.size.height)
        imageScroll.contentOffset = CGPoint(x: scrollWith * CGFloat(self.pageCount.currentPage), y: 0)
        for (index, imageView) in scrollImageVies.enumerated() {
            let tempImage = imageView.image
            let imageOriginSize = tempImage != nil ? tempImage!.size : CGSize(width: 0, height: 0)
            let imageSize = self.getFitSize(maxSize: CGSize(width: HHJShowBigScreenWidth, height: scorllHeight), orSize: imageOriginSize)
            let imageX = (HHJShowBigScreenWidth - imageSize.width) * 0.5
            let imageY = (scorllHeight - imageSize.height) * 0.5
            imageView.frame = CGRect(x: CGFloat(index) * scrollWith + imageX, y: imageY, width: imageSize.width, height: imageSize.height)
        }
        
        let pageCountBottomGap = 40.0
        let pageCountHeight = 20.0
        pageCount.frame = CGRect(x: 0, y: Double(HHJShowBigScreenHeight) - pageCountBottomGap - pageCountHeight, width: Double(HHJShowBigScreenWidth), height: pageCountHeight)
    }
    
    private func setDefaultParam() {
        HHJCurrentPageIndicatorTintColor = UIColor.orange
        HHJBackColor = UIColor.black.withAlphaComponent(0.75)
        HHJpageIndicatorTintColor = UIColor.white
        HHJScrollImageViewHorizonGap = 10
        
        //设置背景和状态栏
        addSubview(bacgView)
        bacgView.frame = CGRect(x: 0, y: 0, width: max(HHJShowBigScreenWidth, HHJShowBigScreenHeight) + 100, height: max(HHJShowBigScreenWidth, HHJShowBigScreenHeight) + 100)
    }
    
    //MARK:- scrollView的代理方法，用来切换pageController的currentPage
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let currentPage = getCurrentCount(scrollView)
        if scrollImageVies.count > currentPage {
            let iv = scrollImageVies[currentPage]
            let originTransForm = CGAffineTransform(scaleX: 1.0, y: 1.0)
            if iv.transform.__equalTo(originTransForm) { return }
            UIView.animate(withDuration: 0.1, animations: {
                iv.transform = originTransForm
            })
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if imageViews != nil && imageViews.count == 1 { return }
        if images != nil && images.count == 1 { return }
        
        let currentPage = getCurrentCount(scrollView)
        if let block = labelTextBlock {
            topLbale.text = block(currentPage)
        } else {
            pageCount.currentPage = currentPage
        }
    }
    
    private func getCurrentCount(_ scrollView: UIScrollView) -> Int{
        let scWidht = UIScreen.main.bounds.size.width
        let contentX = scrollView.contentOffset.x
        var currentPage: Int = Int(contentX / scWidht)
        if currentPage < 0 {
            currentPage = 0
        } else if currentPage > pageCount.numberOfPages {
            currentPage = pageCount.numberOfPages
        }
        return currentPage
    }
    
    @objc private func imageTap(){
        self.showOrDismiss(show: false)
    }
    
    
    private var currentSacle: CGFloat = 1
    @objc private func imageScaleBig(gesture: UIPinchGestureRecognizer) {
        if !isCanScale { return }
        if let iv = gesture.view as? UIImageView {
            var transform = iv.transform
            let scale = gesture.scale - currentSacle + 1.0
            transform = transform.scaledBy(x: scale, y: scale)
            if transform.a < minScale {
                transform = CGAffineTransform(scaleX: minScale, y: minScale)
            } else if transform.a > maxScale {
                transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
            }
            iv.transform = transform
            currentSacle = gesture.scale
            if gesture.state == .ended {
                currentSacle = 1.0
            }
        }
    }
    
    //显示或者消失
    private func showOrDismiss(show: Bool) {
        let currentIndex = self.pageCount.currentPage
        let animationImageView = UIImageView()
        animationImageView.contentMode = HHJContentMode
        animationImageView.clipsToBounds = true
        var orginFrame: CGRect
        if self.imageViews != nil {
            let originImageView = self.imageViews[currentIndex]
            orginFrame = myWindow.convert(originImageView.frame, from: originImageView.superview)
            animationImageView.image = originImageView.image
        } else {
            orginFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
            orginFrame.origin = myWindow.center;
            animationImageView.image = images[currentIndex]
        }
        
        let scollImageView = self.scrollImageVies[currentIndex]
        let scrollView = scollImageView.superview!
        scrollView.alpha = 0
        
        var endFrame = scollImageView.frame
        endFrame.origin.y += scollImageView.superview!.frame.origin.y
        endFrame.origin.x = (HHJShowBigScreenWidth - endFrame.size.width) * 0.5
        
        
        if show {
            myWindow.addSubview(self)
            self.alpha = 0
            animationImageView.frame = orginFrame
        } else {
            self.alpha = 1
            animationImageView.frame = endFrame
        }
        myWindow.addSubview(animationImageView)
        
        UIView.animate(withDuration: showDuration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            if show {
                animationImageView.frame = endFrame
                self.alpha = 1
            } else {
                animationImageView.frame = orginFrame
                self.alpha = 0
            }
        }) { (bool) -> Void in
            animationImageView.removeFromSuperview()
            if show {
                scrollView.alpha = 1
            } else {
                self.removeFromSuperview()
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
    }
}

class HHJPageControl: UIPageControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        let count = subviews.count
        if count > 0 {
            let firstView = subviews.first
            let subViewWidth = firstView!.bounds.size.width
            let subViewHeight = firstView!.bounds.size.height
            let allSubViewWidth = (CGFloat(count) * 2 - 1) * subViewWidth
            let leftGap = (HHJShowBigScreenWidth - allSubViewWidth) * 0.5
            let topGap = (bounds.size.height - subViewHeight) * 0.5
            let subViewWidth2x = subViewWidth * 2
            for (index, subView) in subviews.enumerated() {
                subView.frame = CGRect(x: leftGap + subViewWidth2x * CGFloat(index), y: topGap, width: subViewWidth, height: subViewHeight)
            }
        }
    }
}
