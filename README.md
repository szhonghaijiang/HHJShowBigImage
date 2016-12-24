# HHJShowBigImage
HHJShowBigImage是一个用来放大图片的iOS工具，它继承自UIView，使用它可以很方便的方法图片，点击图片的时候可以很方便的让HHJShowBigImage消失，中间的切换带了动画效果。
# 如何在项目中导入
* HHJShowBigImage只有一个文件，就是HHJShowBigImage.swift，你可以把它直接拖进过程里面。
* 当然我是建议用cocospod导入的，用cocospod导入的最低版本是iOS8：
```
platform :ios, '8.0'
use_frameworks!

pod 'HHJShowBigImage', '~> 0.0.4'
```
# 如何在项目中使用
HHJShowBigImage有两个构造器：

1.public init?(imageViews: [UIImageView], currentIndex: Int)
    这个构造器是需要传入UIImageView的数组，currentIndex表示放大后显示第几张图片，HHJShowBigImage显示时的动画是从UIImageView书中的第currentIndex个UIImageView的尺寸变换的。HHJShowBigImage消失的尺寸变换搭配当前放大的UIImageView。
    
2.public init?(originImages: [UIImage], currentIndex: Int)
    这个构造器是穿件UIImage的数组，currentIndex表示放大后显示第几张图片。
    
* 然后调用show()：show()函数是用来显示图片放大的，它有一个动画的过程。

* 在构造了以后还可以设置以下几个属性:
底部pageControl的颜色
public var HHJCurrentPageIndicatorTintColor: UIColor!
public var HHJpageIndicatorTintColor: UIColor!

背景颜色，默认是 UIColor.black.withAlphaComponent(0.75)
public var HHJBackColor: UIColor!

图片间隔
public var HHJScrollImageViewHorizonGap: CGFloat!

是否显示状态栏
public var hiddenStatusBar: Bool

顶部文字出现的block，如果实现了这个block，则会隐藏底部pageControl
public var labelTextBlock: ((Int) -> String)?

顶部文字的底部图片
public var topLabelImage: UIImage?

图片的contentMode
public var HHJContentMode: UIViewContentMode

显示的动画时长
public var showDuration: Double

是否允许图片缩放，默认允许
public var isCanScale: Bool

缩放的最大比例，默认是4倍
public var maxScale: CGFloat

缩放的最小比例，默认是0.25
public var minScale: CGFloat
