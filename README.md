# HHJShowBigImage
HHJShowBigImage是一个用来放大图片的iOS工具，它继承自UIView，使用它可以很方便的方法图片，点击图片的时候可以很方便的让HHJShowBigImage消失，中间的切换带了动画效果。
# 如何在项目中导入
* HHJShowBigImage只有一个文件，就是HHJShowBigImage.swift，你可以把它直接拖进过程里面。
* 当然我是建议用cocospod导入的，用cocospod导入的最低版本是iOS8：
```
platform :ios, '8.0'
use_frameworks!

pod 'AFNetworking', '~> 3.0'
```
# 如何在项目中使用
HHJShowBigImage有两个构造器：

1.public init?(imageViews: [UIImageView], currentIndex: Int)
    这个构造器是需要传入UIImageView的数组，currentIndex表示放大后显示第几张图片，HHJShowBigImage显示时的动画是从UIImageView书中的第currentIndex个UIImageView的尺寸变换的。HHJShowBigImage消失的尺寸变换搭配当前放大的UIImageView。
    
2.public init?(originImages: [UIImage], currentIndex: Int)
    这个构造器是穿件UIImage的数组，currentIndex表示放大后显示第几张图片。