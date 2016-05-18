//
//  HMShowBigImageView.swift
//  TableView_Swift
//
//  Created by szulmj on 16/3/12.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

var HHJShowBigScreenWidth: CGFloat { return UIScreen.mainScreen().bounds.size.width }
var HHJShowBigScreenHeight: CGFloat { return UIScreen.mainScreen().bounds.size.height}


class HMShowBigImageView: UIView, UIScrollViewDelegate {
    var pageCount: UIPageControl!
    var images: [UIImage]!
    var imageViews: [UIImageView]!
    var scrollImageVies: [UIImageView]!
    var HHJCurrentPageIndicatorTintColor: UIColor!
    var HHJpageIndicatorTintColor: UIColor!
    var HHJBackColor: UIColor!
    var HHJScrollImageViewHorizonGap: CGFloat!
    var imageScroll: UIScrollView!
    let bacgView = UIView()

    init?(imageViews: [UIImageView], currentIndex: Int) {
        super.init(frame: UIScreen.mainScreen().bounds)
        setDefaultParam()
        //先判断是否有图片，如果没有图片则返回
        if imageViews.isEmpty { return nil }

        self.imageViews = imageViews
        self.scrollImageVies = []
        
        
        //创建一个 UIScrollView 用来放置 图片
        let imageScroll = creatScrollView()
        self.imageScroll = imageScroll
        self.addSubview(imageScroll)
        
        let scrollWith = imageScroll.bounds.size.width
        imageScroll.contentSize = CGSize(width: scrollWith * CGFloat(imageViews.count), height: imageScroll.bounds.size.height)
        
        for (index, originImageView) in imageViews.enumerate() {
            creatScrollImageView(nil, originImageView: originImageView, imageScroll: imageScroll, index: index)
        }
        
        if imageViews.count > 0 { creatPageController(imageViews.count, currentPage: currentIndex) }
        
        imageScroll.contentOffset = CGPoint(x: scrollWith * min(CGFloat(currentIndex), CGFloat(imageViews.count - 1)), y: 0)
        self.showOrDismiss(show: true)
    }
    
    init?(originImages: [UIImage], currentIndex: Int) {
        super.init(frame: UIScreen.mainScreen().bounds)
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
        
        for (index, originImage) in originImages.enumerate() {
            creatScrollImageView(originImage, originImageView: nil, imageScroll: imageScroll, index: index)
        }
        
        if originImages.count > 0 { creatPageController(originImages.count, currentPage: currentIndex) }
        
        imageScroll.contentOffset = CGPoint(x: scrollWith * min(CGFloat(currentIndex), CGFloat(originImages.count - 1)), y: 0)
        self.showOrDismiss(show: true)
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
        let imageOriginSize = tempImage != nil ? tempImage!.size : CGSizeZero
        let imageSize = self.getFitSize(maxSize: CGSize(width: HHJShowBigScreenWidth, height: scorllHeight), orSize: imageOriginSize)
        let imageX = (HHJShowBigScreenWidth - imageSize.width) * 0.5
        let imageY = (scorllHeight - imageSize.height) * 0.5
        
        let imageView = UIImageView.init(frame: CGRect(x: CGFloat(index) * scrollWith + imageX, y: imageY, width: imageSize.width, height: imageSize.height))
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HMShowBigImageView.imageTap)))
        imageView.image = tempImage
        scrollImageVies.append(imageView)
        imageScroll.addSubview(imageView)
    }
    
    /**
     创建一个UIScrollview
     */
    private func creatScrollView() -> UIScrollView {
        //获得屏幕长宽和状态栏高度
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let imageScroll = UIScrollView(frame: CGRect(x: 0, y: statusBarHeight, width: HHJShowBigScreenWidth + HHJScrollImageViewHorizonGap, height: HHJShowBigScreenHeight - statusBarHeight))
        imageScroll.showsHorizontalScrollIndicator = false
        imageScroll.pagingEnabled = true
        imageScroll.backgroundColor = UIColor.clearColor()
        imageScroll.delegate = self
        return imageScroll
    }
    
    /**
     创建一个UIPageControl
     */
    private func creatPageController(numberOfPages: Int, currentPage: Int) {
        let pageCountBottomGap = 40.0
        let pageCountHeight = 20.0
        let pageCount = UIPageControl(frame: CGRect(x: 0, y: Double(HHJShowBigScreenHeight) - pageCountBottomGap - pageCountHeight, width: Double(HHJShowBigScreenWidth), height: pageCountHeight))
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        imageScroll.frame = CGRect(x: 0, y: statusBarHeight, width: HHJShowBigScreenWidth + HHJScrollImageViewHorizonGap, height: HHJShowBigScreenHeight - statusBarHeight)
        
        let scrollWith = imageScroll.bounds.size.width
        let scorllHeight = imageScroll.bounds.size.height
        imageScroll.contentSize = CGSize(width: scrollWith * CGFloat(scrollImageVies.count), height: imageScroll.bounds.size.height)
        imageScroll.contentOffset = CGPoint(x: scrollWith * CGFloat(self.pageCount.currentPage), y: 0)
        for (index, imageView) in scrollImageVies.enumerate() {
            let tempImage = imageView.image
            let imageOriginSize = tempImage != nil ? tempImage!.size : CGSizeZero
            let imageSize = self.getFitSize(maxSize: CGSize(width: HHJShowBigScreenWidth, height: scorllHeight), orSize: imageOriginSize)
            let imageX = (HHJShowBigScreenWidth - imageSize.width) * 0.5
            let imageY = (scorllHeight - imageSize.height) * 0.5
            imageView.frame = CGRect(x: CGFloat(index) * scrollWith + imageX, y: imageY, width: imageSize.width, height: imageSize.height)
        }
        
        let pageCountBottomGap = 40.0
        let pageCountHeight = 20.0
        pageCount.frame = CGRect(x: 0, y: Double(HHJShowBigScreenHeight) - pageCountBottomGap - pageCountHeight, width: Double(HHJShowBigScreenWidth), height: pageCountHeight)
        
        let count = pageCount.subviews.count
        if count > 0 {
            let firstView = pageCount.subviews.first
            let subViewWidth = firstView!.bounds.size.width
            let subViewHeight = firstView!.bounds.size.height
            let allSubViewWidth = (CGFloat(count) * 2 - 1) * subViewWidth
            let leftGap = (HHJShowBigScreenWidth - allSubViewWidth) * 0.5
            let topGap = (pageCount.bounds.size.height - subViewHeight) * 0.5
            let subViewWidth2x = subViewWidth * 2
            for (index, subView) in pageCount.subviews.enumerate() {
                subView.frame = CGRect(x: leftGap + subViewWidth2x * CGFloat(index), y: topGap, width: subViewWidth, height: subViewHeight)
            }
        }
    }
    
    private func setDefaultParam() {
        HHJCurrentPageIndicatorTintColor = UIColor.orangeColor()
        HHJBackColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
        HHJpageIndicatorTintColor = UIColor.whiteColor()
        HHJScrollImageViewHorizonGap = 10
        
        //设置背景和状态栏
        bacgView.backgroundColor = HHJBackColor
        addSubview(bacgView)
        bacgView.frame = CGRect(x: 0, y: 0, width: max(HHJShowBigScreenWidth, HHJShowBigScreenHeight) + 100, height: max(HHJShowBigScreenWidth, HHJShowBigScreenHeight) + 100)
    }
    
    //MARK:- scrollView的代理方法，用来切换pageController的currentPage
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if imageViews != nil && imageViews.count == 1 { return }
        if images != nil && images.count == 1 { return }
        
        let scWidht = UIScreen.mainScreen().bounds.size.width
        let contentX = scrollView.contentOffset.x
        var currentPage: Int = Int(contentX / scWidht)
        if currentPage < 0 {
            currentPage = 0
        } else if currentPage > pageCount.numberOfPages {
            currentPage = pageCount.numberOfPages
        }
        pageCount.currentPage = currentPage
    }
    
    @objc private func imageTap(){
        self.showOrDismiss(show: false)
    }
    
    //显示或者消失
    private func showOrDismiss(show show: Bool) {
        let currentIndex = self.pageCount.currentPage
        let window = UIApplication.sharedApplication().keyWindow!
        let animationImageView = UIImageView()
        var orginFrame: CGRect
        if self.imageViews != nil {
            let originImageView = self.imageViews[currentIndex]
            orginFrame = window.convertRect(originImageView.frame, fromView: originImageView.superview)
            animationImageView.image = originImageView.image
        } else {
            orginFrame = CGRectZero
            orginFrame.origin = window.center;
            animationImageView.image = images[currentIndex]
        }
        
        let scollImageView = self.scrollImageVies[currentIndex]
        let scrollView = scollImageView.superview!
        scrollView.alpha = 0
        
        var endFrame = scollImageView.frame
        endFrame.origin.y += scollImageView.superview!.frame.origin.y
        endFrame.origin.x = (HHJShowBigScreenWidth - endFrame.size.width) * 0.5
        
        
        if show {
            window.addSubview(self)
            self.alpha = 0
            animationImageView.frame = orginFrame
        } else {
            self.alpha = 1
            animationImageView.frame = endFrame
        }
        window.addSubview(animationImageView)
        
        UIView.animateWithDuration(0.25, delay: 0, options: .OverrideInheritedCurve, animations: { () -> Void in
            
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        fatalError("init(coder:) has not been implemented")
    }
}
